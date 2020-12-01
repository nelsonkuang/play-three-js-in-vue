/*
pbr的三个条件
判断一种 PBR 光照模型是否是基于物理的，必须满足以下三个条件（不用担心，我们很快就会了解它们的）：

基于微平面(Microfacet)的表面模型。
能量守恒。
应用基于物理的BRDF。

BRDF 的 反射率方程 公式

c 表示表面颜色, albedo

入射（光）方向 ωi，出射（观察）方向 ωo

Lo : 看到的颜色最终值, 表示了从 ωo 方向上观察，光线投射到点 p 上反射出来的辐照度。

D : 正态分布函数 ( Normal Distribution Function, 简称 ndf )

F : 菲涅尔方程 ( Fresnel Rquation )

G : 几何函数( Geometry Function )

ks : 也就是 F ( 在实际运算中不用乘以这个 ks, 因为在 DFG 中已经乘过了 )

kd : 1 - ks, 能量守恒

Li : 光的颜色 ( 也就是辐照度, 经过衰减的颜色 )
关于多光源计算
这也让我们回到了对于表面的半球领域(hemisphere) Ω 的积分 ∫ 上。由于我们事先知道的所有贡献光源的位置，因此对物体表面上的一个点着色并不需要我们尝试去求解积分。我们可以直接拿光源的（已知的）数目，去计算它们的总辐照度，因为每个光源仅仅只有一个方向上的光线会影响物体表面的辐射率。这使得PBR对直接光源的计算相对简单，因为我们只需要有效地遍历所有有贡献的光源。而当我们后来把环境照明也考虑在内的IBL教程中，我们就必须采取积分去计算了，这是因为光线可能会在任何一个方向入射。

vec3 Lo = vec3(0.0); // 出射光, 也就是看到的物体颜色 (不含环境光)
for(int i = 0; i < 4; ++i) // 4 是光源个数
{
    Lo += (kD * albedo / PI + specular) * radiance * NdotL; // albedo 参与
}

Cook-Torrance BRDF
Cook-Torrance BRDF的镜面反射部分包含三个函数，此外分母部分还有一个标准化因子 。字母D，F与G分别代表着一种类型的函数，各个函数分别用来近似的计算出表面反射特性的一个特定部分。三个函数分别为正态分布函数(Normal Distribution Function)，菲涅尔方程(Fresnel Rquation)和几何函数(Geometry Function)：

D : 正态分布函数 ( Normal Distribution Function, 简称 ndf ) ：估算在受到表面粗糙度的影响下，取向方向与中间向量一致的微平面的数量。这是用来估算微平面的主要函数。
G : 几何函数( Geometry Function ) ：描述了微平面自成阴影的属性。当一个平面相对比较粗糙的时候，平面表面上的微平面有可能挡住其他的微平面从而减少表面所反射的光线。
F : 菲涅尔方程 ( Fresnel Rquation ) ：菲涅尔方程描述的是在不同的表面角下表面所反射的光线所占的比率。


下面公式中的 h 是 半角向量, 也就是 vec3 H = normalize(V + L)
*/

// #extension GL_EXT_shader_texture_lod : enable
precision highp float;
precision highp int;

#define PI		3.14159265359

uniform vec3 cameraPosition;
// uniform vec3  albedo;
// uniform float metallic;
// uniform float roughness;
uniform sampler2D albedoMap;
uniform sampler2D metallicMap;
uniform sampler2D roughnessMap;
uniform float ao;

// lights
uniform vec3 lightPositions[4];
uniform vec3 lightColors[4];

#define GLSLIFY 1
varying vec2 vUv;
varying vec3 worldNormal;
varying vec3 worldPosition;
varying vec3 vNormal;

// D - 正态分布函数
// 在这里 h 表示用来与平面上微平面做比较用的 中间向量 ( 也叫半角向量 ) ，而 a 表示表面 粗糙度
// 当α非常接近0的时候，光照集中在一点，其他方向会完全看不到光线。
float DistributionGGX(vec3 N, vec3 H, float roughness) { // roughness 参与
    float a      = roughness*roughness;
    float a2     = a*a;
    float NdotH  = max(dot(N, H), 0.0);
    float NdotH2 = NdotH*NdotH;

    float nom   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;

    return nom / denom;
}

// F - 菲涅尔方程
// 通过预先计算电介质与导体的 F0 值，我们可以对两种类型的表面使用相同的Fresnel-Schlick近似，但是如果是 金属 表面的话就需要对基础 反射率 添加色彩。我们一般是按下面这个样子来实现的：
// F0 材料对应值表
// shader 中的 F0 参数根据物体的材料属性填入对应的值会显得更接近于真实世界.

vec3 fresnelSchlick(float cosTheta, vec3 F0) {
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

// G - 几何函数
// k 由 a ( 粗糙度 ) 求得
float GeometrySchlickGGX(float NdotV, float roughness) { // roughness 参与
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float nom   = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return nom / denom;
}

// 为了有效的估算几何部分，需要将观察方向（几何遮蔽(Geometry Obstruction)）和光线方向向量（几何阴影(Geometry Shadowing)）都考虑进去。我们可以使用史密斯法(Smith’s method)来把两者都纳入其中：
// 效果就是粗糙度越大，亮度越低。但视线和光线越接近垂直，受粗糙度的影响就越小
float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness) { // roughness 参与
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2  = GeometrySchlickGGX(NdotV, roughness);
    float ggx1  = GeometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}


void main() {
	  vec3 albedoRgb = texture2D(albedoMap, vUv).rgb;
	  vec3 albedo = vec3(pow(albedoRgb.r, 2.2), pow(albedoRgb.g, 2.2), pow(albedoRgb.b, 2.2));
    float metallic  = texture2D(metallicMap, vUv).r;
    float roughness = texture2D(roughnessMap, vUv).r;

    vec3 N = vNormal;
    vec3 V = normalize(cameraPosition - worldPosition);

    vec3 F0 = vec3(0.04); 
    F0 = mix(F0, albedo, metallic); // albedo 参与, metallic 参与, F0 参与

    // reflectance equation
    vec3 Lo = vec3(0.0);
    for(int i = 0; i < 4; ++i) {
        // calculate per-light radiance
        vec3 L = normalize(lightPositions[i] - worldPosition);
        vec3 H = normalize(V + L);
        float distance    = length(lightPositions[i] - worldPosition);
        float attenuation = 1.0 / (distance * distance);
        vec3 radiance     = lightColors[i] * attenuation; // light color 参与     

        // cook-torrance brdf
        float NDF = DistributionGGX(N, H, roughness); // roughness 参与
        float G   = GeometrySmith(N, V, L, roughness); // roughness 参与
        vec3 F    = fresnelSchlick(max(dot(H, V), 0.0), F0);       

        vec3 kS = F;
        vec3 kD = vec3(1.0) - kS;
        kD *= 1.0 - metallic; // metallic 参与

        vec3 nominator    = NDF * G * F;
        float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.001; // 分母项中加了一个0.001为了避免出现除零错误
        vec3 specular     = nominator / denominator;

        // add to outgoing radiance Lo
        float NdotL = max(dot(N, L), 0.0);                
        Lo += (kD * albedo / PI + specular) * radiance * NdotL; // albedo 参与
    }   

    vec3 ambient = vec3(0.03) * albedo * ao; // 环境光 term, ao 参与
    vec3 color = ambient + Lo;

    color = color / (color + vec3(1.0));
    color = pow(color, vec3(1.0/2.2));  // 转到 gamma 空间

    // gl_FragColor = vec4(color, 1.0);
		// gl_FragColor = vec4(albedoRgb, 1.0);
		gl_FragColor = vec4(normalize(color), 1.0);
}
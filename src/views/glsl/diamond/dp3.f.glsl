#extension GL_OES_standard_derivatives : enable
#extension GL_EXT_shader_texture_lod : enable
precision highp float;
precision highp int;
#define HIGH_PRECISION
#define SHADER_NAME ShaderMaterial
#define USE_CLEARCOAT USE_CLEARCOAT
#define GAMMA_FACTOR 2
#define USE_ENVMAP
#define ENVMAP_TYPE_CUBE
#define ENVMAP_MODE_REFLECTION
#define ENVMAP_BLENDING_MULTIPLY
#define TEXTURE_LOD_EXT
uniform mat4 viewMatrix;
uniform vec3 cameraPosition;
#define TONE_MAPPING
#ifndef saturate
#define saturate(a) clamp( a, 0.0, 1.0 )
#endif
uniform float toneMappingExposure;
uniform float toneMappingWhitePoint;
vec3 LinearToneMapping( vec3 color ) {
	return toneMappingExposure * color;
}
vec3 ReinhardToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	return saturate( color / ( vec3( 1.0 ) + color ) );
}
#define Uncharted2Helper( x ) max( ( ( x * ( 0.15 * x + 0.10 * 0.50 ) + 0.20 * 0.02 ) / ( x * ( 0.15 * x + 0.50 ) + 0.20 * 0.30 ) ) - 0.02 / 0.30, vec3( 0.0 ) )
vec3 Uncharted2ToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	return saturate( Uncharted2Helper( color ) / Uncharted2Helper( vec3( toneMappingWhitePoint ) ) );
}
vec3 OptimizedCineonToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	color = max( vec3( 0.0 ), color - 0.004 );
	return pow( ( color * ( 6.2 * color + 0.5 ) ) / ( color * ( 6.2 * color + 1.7 ) + 0.06 ), vec3( 2.2 ) );
}
vec3 ACESFilmicToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	return saturate( ( color * ( 2.51 * color + 0.03 ) ) / ( color * ( 2.43 * color + 0.59 ) + 0.14 ) );
}
vec3 toneMapping( vec3 color ) { return LinearToneMapping( color ); }

vec4 LinearToLinear( in vec4 value ) {
	return value;
}
vec4 GammaToLinear( in vec4 value, in float gammaFactor ) {
	return vec4( pow( value.rgb, vec3( gammaFactor ) ), value.a );
}
vec4 LinearToGamma( in vec4 value, in float gammaFactor ) {
	return vec4( pow( value.rgb, vec3( 1.0 / gammaFactor ) ), value.a );
}
vec4 sRGBToLinear( in vec4 value ) {
	return vec4( mix( pow( value.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), value.rgb * 0.0773993808, vec3( lessThanEqual( value.rgb, vec3( 0.04045 ) ) ) ), value.a );
}
vec4 LinearTosRGB( in vec4 value ) {
	return vec4( mix( pow( value.rgb, vec3( 0.41666 ) ) * 1.055 - vec3( 0.055 ), value.rgb * 12.92, vec3( lessThanEqual( value.rgb, vec3( 0.0031308 ) ) ) ), value.a );
}
vec4 RGBEToLinear( in vec4 value ) {
	return vec4( value.rgb * exp2( value.a * 255.0 - 128.0 ), 1.0 );
}
vec4 LinearToRGBE( in vec4 value ) {
	float maxComponent = max( max( value.r, value.g ), value.b );
	float fExp = clamp( ceil( log2( maxComponent ) ), -128.0, 127.0 );
	return vec4( value.rgb / exp2( fExp ), ( fExp + 128.0 ) / 255.0 );
}
vec4 RGBMToLinear( in vec4 value, in float maxRange ) {
	return vec4( value.rgb * value.a * maxRange, 1.0 );
}
vec4 LinearToRGBM( in vec4 value, in float maxRange ) {
	float maxRGB = max( value.r, max( value.g, value.b ) );
	float M = clamp( maxRGB / maxRange, 0.0, 1.0 );
	M = ceil( M * 255.0 ) / 255.0;
	return vec4( value.rgb / ( M * maxRange ), M );
}
vec4 RGBDToLinear( in vec4 value, in float maxRange ) {
	return vec4( value.rgb * ( ( maxRange / 255.0 ) / value.a ), 1.0 );
}
vec4 LinearToRGBD( in vec4 value, in float maxRange ) {
	float maxRGB = max( value.r, max( value.g, value.b ) );
	float D = max( maxRange / maxRGB, 1.0 );
	D = min( floor( D ) / 255.0, 1.0 );
	return vec4( value.rgb * ( D * ( 255.0 / maxRange ) ), D );
}
const mat3 cLogLuvM = mat3( 0.2209, 0.3390, 0.4184, 0.1138, 0.6780, 0.7319, 0.0102, 0.1130, 0.2969 );
vec4 LinearToLogLuv( in vec4 value )  {
	vec3 Xp_Y_XYZp = cLogLuvM * value.rgb;
	Xp_Y_XYZp = max( Xp_Y_XYZp, vec3( 1e-6, 1e-6, 1e-6 ) );
	vec4 vResult;
	vResult.xy = Xp_Y_XYZp.xy / Xp_Y_XYZp.z;
	float Le = 2.0 * log2(Xp_Y_XYZp.y) + 127.0;
	vResult.w = fract( Le );
	vResult.z = ( Le - ( floor( vResult.w * 255.0 ) ) / 255.0 ) / 255.0;
	return vResult;
}
const mat3 cLogLuvInverseM = mat3( 6.0014, -2.7008, -1.7996, -1.3320, 3.1029, -5.7721, 0.3008, -1.0882, 5.6268 );
vec4 LogLuvToLinear( in vec4 value ) {
	float Le = value.z * 255.0 + value.w;
	vec3 Xp_Y_XYZp;
	Xp_Y_XYZp.y = exp2( ( Le - 127.0 ) / 2.0 );
	Xp_Y_XYZp.z = Xp_Y_XYZp.y / value.y;
	Xp_Y_XYZp.x = value.x * Xp_Y_XYZp.z;
	vec3 vRGB = cLogLuvInverseM * Xp_Y_XYZp.rgb;
	return vec4( max( vRGB, 0.0 ), 1.0 );
}
vec4 mapTexelToLinear( vec4 value ) { return GammaToLinear( value, float( GAMMA_FACTOR ) ); }
vec4 matcapTexelToLinear( vec4 value ) { return GammaToLinear( value, float( GAMMA_FACTOR ) ); }
vec4 envMapTexelToLinear( vec4 value ) { return LogLuvToLinear( value ); }
vec4 emissiveMapTexelToLinear( vec4 value ) { return GammaToLinear( value, float( GAMMA_FACTOR ) ); }
vec4 linearToOutputTexel( vec4 value ) { return LinearToGamma( value, float( GAMMA_FACTOR ) ); }

precision highp float;
#define GLSLIFY 1
#define _PCFx1
// #define USE_CLEARCOAT

//clearCoat
uniform bool useClearCoat;
uniform vec3 uClearCoatTint;
uniform float uClearCoatThickness;
uniform float uClearCoatF0;
uniform float uClearCoatFactor;
uniform float uClearCoatRoughnessFactor;
uniform float uClearCoatIor;
uniform int uSpecularPeak;
//SSS效果所需深度贴图

uniform float uSubsurfaceTranslucencyThicknessFactor;
uniform vec3 uSubsurfaceTranslucencyColor;
uniform float uSubsurfaceTranslucencyFactor;

//光照贴图模式相乘或者相加
uniform int uMultiplyLightMap;
uniform bool receiveShadow;
//自发光模式相乘或者相加
uniform int uEmitMultiplicative;
//环境光
uniform vec3 ambientLightColor;
uniform sampler2D map;
uniform sampler2D mapMask;
uniform int map_uv;
uniform mat3 mapTransform;
uniform int alphaMap_uv;
uniform mat3 alphaMapTransform;
uniform int emissiveMap_uv;
uniform mat3 emissiveMapTransform;
uniform int roughnessMap_uv;
uniform mat3 roughnessMapTransform;
uniform int metalnessMap_uv;
uniform mat3 metalnessMapTransform;
uniform int aoMap_uv;
uniform mat3 aoMapTransform;
uniform int bumpMap_uv;
uniform mat3 bumpMapTransform;
uniform int lightMap_uv;
uniform mat3 lightMapTransform;

uniform mat4 modelViewMatrix;
uniform sampler2D alphaMap;
#ifdef PANORAMA_ENVIRMENT
 uniform sampler2D envMap;
#else

uniform samplerCube envMap;//环境球相关自动传入
#endif
uniform vec2 uTextureEnvironmentSpecularPBRTextureSize;//环境球相关自动传入
uniform vec2 uTextureEnvironmentSpecularPBRLodRange;//环境球相关自动传入
uniform sampler2D emissiveMap;
uniform vec3 emissive;
uniform float emissiveIntensity;
uniform int uDrawOpaque;
uniform sampler2D roughnessMap;
uniform float roughness;
uniform sampler2D metalnessMap;
uniform float metalness;
uniform vec3 diffuse;
uniform float uSpecularF0Factor;
uniform float opacity;
uniform sampler2D aoMap;
uniform sampler2D sIntegrateBRDF;//环境球相关自动传入
uniform float aoMapIntensity;
uniform int uOpacityAdditive;
uniform float uEnvironmentExposure;//环境球相关自动传入
uniform mat4 uEnvironmentTransform;//环境球相关自动传入
uniform vec4 uHalton;//环境球相关自动传入

uniform vec3 uDiffuseSPH[9];//环境球相关自动传入
uniform int uAOPBROccludeSpecular;
//缩放法线XY值
uniform float uNormalMapFactor;
uniform int uNormalMapFlipY;
uniform int normalMap_uv;
uniform mat3 normalMapTransform;
//varying变量
varying vec3 vViewNormal;
varying vec2 vTexCoord1;
varying vec3 vViewPosition;
varying vec3 vWorldPosition;
const float PI =3.1415926;
varying vec3 vWorldNormal;
#ifdef USE_TANGENT
    varying vec4 vViewTangent;
#endif
#ifdef USE_COLOR
	varying vec3 vColor;
#endif
//最多支持四个UV以及UV  transform
#ifdef USE_UV2
varying vec2 vTexCoord2;
#endif
#ifdef USE_UV3
varying vec2 vTexCoord3;
#endif
#ifdef USE_UV4
varying vec2 vTexCoord4;
#endif

#ifdef USE_LIGHTMAP
	uniform sampler2D lightMap;
	uniform float lightMapIntensity;
#endif
const mat3 LUVInverse = mat3( 6.0013, -2.700, -1.7995, -1.332, 3.1029, -5.7720, 0.3007, -1.088, 5.6268 );
float sRGBToLinear(const in float color) { return  color < 0.04045 ? color * (1.0 / 12.92) : pow((color + 0.055) * (1.0 / 1.055), 2.4); }
vec3 sRGBToLinear(const in vec3 color) { return vec3( color.r < 0.04045 ? color.r * (1.0 / 12.92) : pow((color.r + 0.055) * (1.0 / 1.055), 2.4),  color.g < 0.04045 ? color.g * (1.0 / 12.92) : pow((color.g + 0.055) * (1.0 / 1.055), 2.4),  color.b < 0.04045 ? color.b * (1.0 / 12.92) : pow((color.b + 0.055) * (1.0 / 1.055), 2.4)); }
const float PackUpscale = 256. / 255.; // fraction -> 0..1 (including 1)
const float UnpackDownscale = 255. / 256.; // 0..1 -> fraction (excluding 1)
const vec3 PackFactors = vec3( 256. * 256. * 256., 256. * 256.,  256. );
const vec4 UnpackFactors = UnpackDownscale / vec4( PackFactors, 1. );
float linearTosRGB(const in float color) { return  color < 0.0031308 ? color * 12.92 : 1.055 * pow(color, 1.0/2.4) - 0.055; }
vec3 linearTosRGB(const in vec3 color) { return vec3( color.r < 0.0031308 ? color.r * 12.92 : 1.055 * pow(color.r, 1.0/2.4) - 0.055,  color.g < 0.0031308 ? color.g * 12.92 : 1.055 * pow(color.g, 1.0/2.4) - 0.055,  color.b < 0.0031308 ? color.b * 12.92 : 1.055 * pow(color.b, 1.0/2.4) - 0.055); }
vec4 linearTosRGB(const in vec4 color) { return vec4( color.r < 0.0031308 ? color.r * 12.92 : 1.055 * pow(color.r, 1.0/2.4) - 0.055,  color.g < 0.0031308 ? color.g * 12.92 : 1.055 * pow(color.g, 1.0/2.4) - 0.055,  color.b < 0.0031308 ? color.b * 12.92 : 1.055 * pow(color.b, 1.0/2.4) - 0.055, color.a); }
float adjustRoughnessNormalMap(const in float roughness, const in vec3 normal) {
    // Based on The Order : 1886 SIGGRAPH course notes implementation (page 21 notes)
    float nlen2 = dot(normal, normal);
    if (nlen2 < 1.0) {
        float nlen = sqrt(nlen2);
        float kappa = (3.0 * nlen -  nlen2 * nlen) / (1.0 - nlen2);
        // http://www.frostbite.com/2014/11/moving-frostbite-to-pbr/
        // page 91 : they use 0.5/kappa instead
        return min(1.0, sqrt(roughness * roughness + 1.0 / kappa));
    }
    return roughness;
}
vec3 computeNormalFromTangentSpaceNormalMap(const in vec4 tangent, const in vec3 normal, const in vec3 texnormal)
{
    vec3 tang = vec3(0.0,1.0,0.0);
    if (length(tangent.xyz) != 0.0) {
        tang = normalize(tangent.xyz);
    }
    vec3 B = tangent.w * cross(normal, tang);
    vec3 outnormal = texnormal.x*tang + texnormal.y*B + texnormal.z*normal;
    return normalize(outnormal);
}
vec3 transformNormal(const in float factor, in vec3 normal, const in vec3 t, const in vec3 b, in vec3 n) {
    normal.xy = factor * normal.xy;
    return normalize(normal.x * t + normal.y * b + normal.z * n);
}
vec3 LUVToRGB( const in vec4 vLogLuv ) {
    float Le = vLogLuv.z * 255.0 + vLogLuv.w;
    vec3 Xp_Y_XYZp;
    Xp_Y_XYZp.y = exp2((Le - 127.0) / 2.0);
    Xp_Y_XYZp.z = Xp_Y_XYZp.y / vLogLuv.y;
    Xp_Y_XYZp.x = vLogLuv.x * Xp_Y_XYZp.z;
    vec3 vRGB = LUVInverse * Xp_Y_XYZp;
    return max(vRGB, 0.0);
}
vec2 getCurrentUv(int type){
     if(type==0){
         return vTexCoord1;
     }else if(type==1){
        #ifdef USE_UV2
            return vTexCoord2;
        #else
            return vTexCoord1;
        #endif
     }else if(type==2){
        #ifdef USE_UV3
            return vTexCoord3;
        #else
            return vTexCoord1;
        #endif
     }else if(type==3){
        #ifdef USE_UV4
            return vTexCoord4;
        #else
            return vTexCoord1;
        #endif
     }
     return vTexCoord1;
    
}
#ifdef USE_SSS
        #define CURRENT_DIR 1
            uniform sampler2D translucencyMap;
            uniform int translucency_uv;
            uniform mat3 translucencyMapTransform;
            #ifdef USETRANSLUCENCYMAP
                    float getTranslucency(){
                        vec2 uv0=getCurrentUv(translucency_uv);
                        uv0=(translucencyMapTransform*vec3(uv0,1.0)).xy;
                    return texture2D(translucencyMap,uv0).r;
                }
            
            #endif
  
#else
           #define CURRENT_DIR 0
#endif

float punctualLightIntensityToIrradianceFactor( const in float lightDistance, const in float cutoffDistance, const in float decayExponent ) {
    #if defined ( PHYSICALLY_CORRECT_LIGHTS )
        // based upon Frostbite 3 Moving to Physically-based Rendering
        // page 32, equation 26: E[window1]
        // https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf
        // this is intended to be used on spot and point lights who are represented as luminous intensity
        // but who must be converted to luminous irradiance for surface lighting calculation
        float distanceFalloff = 1.0 / max( pow( lightDistance, decayExponent ), 0.01 );
        if( cutoffDistance > 0.0 ) {
            distanceFalloff *= pow2( saturate( 1.0 - pow4( lightDistance / cutoffDistance ) ) );
        }
        return distanceFalloff;
    #else
        if( cutoffDistance > 0.0 && decayExponent > 0.0 ) {
            return pow( saturate( -lightDistance / cutoffDistance + 1.0 ), decayExponent );
        }
        return 1.0;
    #endif 
}

#if 1 > 0
    struct DirectionalLight {
        vec3 direction;
        vec3 color;
        int shadow;
        float shadowBias;
        float shadowRadius;
        vec2 shadowMapSize;
    };
    uniform DirectionalLight directionalLights[ 1 ];
   
#endif
#if 0 > 0
    struct PointLight {
        vec3 position;
        vec3 color;
        float distance;
        float decay;
        int shadow;
        float shadowBias;
        float shadowRadius;
        vec2 shadowMapSize;
        float shadowCameraNear;
        float shadowCameraFar;
    };
    uniform PointLight pointLights[ 0 ];

    

#endif
#if 0 > 0
    struct SpotLight {
        vec3 position;
        vec3 direction;
        vec3 color;
        float distance;
        float decay;
        float coneCos;
        float penumbraCos;
        int shadow;
        float shadowBias;
        float shadowRadius;
        vec2 shadowMapSize;
    };
    uniform SpotLight spotLights[ 0 ];
#endif
float getMaterialF0() {
    return uSpecularF0Factor;
}
float getMaterialMetalness() {
    #ifdef USE_METALNESSMAP
    vec2 uv0=getCurrentUv(metalnessMap_uv);
         uv0=(metalnessMapTransform*vec3(uv0,1.0)).xy;
        return metalness * (texture2D(metalnessMap,uv0).b);
    #endif
    return metalness;
}
vec4 getMaterialAlbedo() {
    vec4 albedo;
    #ifdef USE_MAP
         vec2 uv0=getCurrentUv(map_uv);
              uv0=(mapTransform*vec3(uv0,1.0)).xy;
         vec4 mapColor=texture2D(map, uv0);
              mapColor=mapTexelToLinear( mapColor);
              //albedo.rgb = sRGBToLinear(diffuse) * mapColor.rgb;
              albedo.rgb =sRGBToLinear(diffuse) * mapColor.rgb;
              albedo.a=mapColor.a;
    #else
              //albedo.rgb=sRGBToLinear(diffuse);
              albedo.rgb=sRGBToLinear(diffuse);
              albedo.a=1.0;
    #endif
    #ifdef USE_COLOR
	         albedo.rgb *= vColor;
    #endif
        return albedo;
}
vec4 getMapMask() {
    vec4 albedo;
    #ifdef MAP_MaskMul
        #ifdef MAP_MASK
            vec2 uv0=getCurrentUv(map_uv);
            uv0=(mapTransform*vec3(uv0,1.0)).xy;
            albedo=texture2D(mapMask, uv0);
        #else
            albedo=vec4(1.0);
        #endif
    #else
        #ifdef MAP_MASK
            vec2 uv0=getCurrentUv(map_uv);
            uv0=(mapTransform*vec3(uv0,1.0)).xy;
            albedo=texture2D(mapMask, uv0);
        #else
            albedo=vec4(0.0);
        #endif
    #endif
        return albedo;
}
float getMaterialRoughness() {      
    #ifdef USE_ROUGHNESSMAP
      vec2 uv0=getCurrentUv(roughnessMap_uv);
           uv0=(roughnessMapTransform*vec3(uv0,1.0)).xy;
           return roughness*(texture2D(roughnessMap,uv0).g);
    #endif
          return roughness;
}
float getMaterialAO() {
    #ifdef USE_AOMAP
        vec2 uv0=getCurrentUv(aoMap_uv);
             uv0=(aoMapTransform*vec3(uv0,1.0)).xy;
        return mix(1.0, (texture2D(aoMap, uv0).r), aoMapIntensity);
    #endif
       return 1.0;
    }
vec3 getMaterialEmitColor() {
    #ifdef USE_EMISSIVEMAP
        vec2 uv0=getCurrentUv(emissiveMap_uv);
             uv0=(emissiveMapTransform*vec3(uv0,1.0)).xy;
        vec4 color=texture2D(emissiveMap, uv0);
             color=emissiveMapTexelToLinear(color);
        // return sRGBToLinear(emissive) * color.rgb*emissiveIntensity;
         return emissive * color.rgb*emissiveIntensity;
    #endif
        // return sRGBToLinear(emissive)*emissiveIntensity;
         return emissive*emissiveIntensity;
    }
float getMaterialClearCoatRoughness() {
        return uClearCoatRoughnessFactor;
}
float getMaterialClearCoat() {
        return uClearCoatFactor;
    }
float linearrgb_to_srgb1(const in float c, const in float gamma) {
    float v = 0.0;
    if(c < 0.0031308) {
        if ( c > 0.0)
            v = c * 12.92;
    } else {
        v = 1.055 * pow(c, 1.0/ gamma) - 0.055;
    }
    return v;
}
//编码样式应为驼峰式，但SRGB或HDR等杂音符号除外
// coding style should be camel case except for acronyme like SRGB or HDR
vec4 linearTosRGB(const in vec4 col_from, const in float gamma){
    vec4 col_to;
    col_to.r = linearrgb_to_srgb1(col_from.r, gamma);
    col_to.g = linearrgb_to_srgb1(col_from.g, gamma);
    col_to.b = linearrgb_to_srgb1(col_from.b, gamma);
    col_to.a = col_from.a;
    return col_to;
}
vec3 computeDiffuseSPH(const in vec3 normal) {
    vec3 n = vec4(uEnvironmentTransform * vec4(normal,1.0)).xyz;
    vec3 result =
    uDiffuseSPH[0] +
    uDiffuseSPH[1] * n.y +
    uDiffuseSPH[2] * n.z +
    uDiffuseSPH[3] * n.x +
    uDiffuseSPH[4] * n.y * n.x +
    uDiffuseSPH[5] * n.y * n.z +
    uDiffuseSPH[6] * (3.0 * n.z * n.z - 1.0) +
    uDiffuseSPH[7] * (n.z * n.x) +
    uDiffuseSPH[8] * (n.x * n.x - n.y * n.y);
    return max(result, vec3(0.0));
}
vec3 getSpecularDominantDir(const in vec3 N, const in vec3 R, const in float realRoughness) {
     float smoothness = 1.0 - realRoughness;
        float lerpFactor = smoothness * (sqrt(smoothness) + realRoughness);
        // The result is not normalized as we fetch in a cubemap
        return mix(N, R, lerpFactor);
}
//roughness转lod
float linRoughnessToMipmap(const in float roughnessLinear) {
    return sqrt(roughnessLinear);
}
#ifdef USE_ENVMAP

#ifdef PANORAMA_ENVIRMENT
    vec2 computeUVForMipmap(const in float level, const in vec2 uv) {
            // width for level
            float widthForLevel = exp2(uTextureEnvironmentSpecularPBRLodRange.x - level);
            // the height locally for the level in pixel
            // to opimitize a bit we scale down the v by two in the inputs uv
            float heightForLevel = widthForLevel * 0.5;
            // compact version
            float texelSize = 1.0 / uTextureEnvironmentSpecularPBRTextureSize.x;
            vec2 uvSpaceLocal =  vec2(1.0) + uv * vec2(widthForLevel - 2.0, heightForLevel - 2.0);
            uvSpaceLocal.y += uTextureEnvironmentSpecularPBRTextureSize.x - widthForLevel;
            return uvSpaceLocal * texelSize;
            }
    //for y up

    vec2 normalToPanoramaUVY(const in vec3 dir) {
        float n = length(dir.xz);
        // to avoid bleeding the max(-1.0,dir.x / n) is needed
        vec2 pos = vec2((n > 0.0000001) ? max(-1.0, dir.x / n) : 0.0, dir.y);
        // fix edge bleeding
        if (pos.x > 0.0) pos.x = min(0.999999, pos.x);
        pos = acos(pos) * 0.3183098861837907; 
        // inv_pi
        pos.x = (dir.z > 0.0) ? pos.x * 0.5 : 1.0 - (pos.x * 0.5);
        // shift u to center the panorama to -z
        pos.x = mod(pos.x - 0.25 + 1.0, 1.0);
        pos.y = 1.0 - pos.y;
        return pos;
    }
    vec3 prefilterEnvMapPanorama(const in float rLinear, const in vec3 R) {
        float lod = min(uTextureEnvironmentSpecularPBRLodRange.x, linRoughnessToMipmap(rLinear) * uTextureEnvironmentSpecularPBRLodRange.y);
        vec2 uvBase = normalToPanoramaUVY(R);
        // // we scale down v here because it avoid to do twice in sub functions
        // uvBase.y *= 0.5;
        vec3 texel0 = LUVToRGB(texture2D(envMap, computeUVForMipmap(floor(lod), uvBase)));
        vec3 texel1 = LUVToRGB(texture2D(envMap, computeUVForMipmap(ceil(lod), uvBase)));
        return mix(texel0, texel1, fract(lod));
        }
#else
    vec3 prefilterEnvMapCube(const in float rLinear, const in vec3 R) {
        vec3 dir = R;
        //求取lod
        float lod = min(uTextureEnvironmentSpecularPBRLodRange.x, linRoughnessToMipmap(rLinear) * uTextureEnvironmentSpecularPBRLodRange.y);
        //https://seblagarde.wordpress.com/2012/06/10/amd-cubemapgen-for-physically-based-rendering/
        float scale = 1.0 - exp2(lod) / uTextureEnvironmentSpecularPBRTextureSize.x;
        // vec3 absDir = abs(dir);
        vec3 absDir = abs(dir);
       float M = max(max(absDir.x, absDir.y), absDir.z);
    
    if (absDir.x != M) dir.x *= scale;
    if (absDir.y != M) dir.y *= scale;
    if (absDir.z != M) dir.z *= scale;
        return LUVToRGB(textureCubeLodEXT(envMap, dir, lod));
    }

#endif
vec3 getPrefilteredEnvMapColor(const in vec3 normal, const in vec3 eyeVector, const in float roughness, const in vec3 frontNormal) {
    // vec3 R = reflect(-eyeVector, normal);
     vec3 R = reflect(-eyeVector, normal);
    //重要性采样获取采样方向根据法线，反射方向以及粗糙度
    R = getSpecularDominantDir(normal, R, roughness);
    //获取环境球颜色
    #ifdef PANORAMA_ENVIRMENT
     vec3 prefilteredColor = prefilterEnvMapPanorama(roughness, vec4(uEnvironmentTransform * vec4(R,1.0)).xyz);
    #else
    vec3 prefilteredColor = prefilterEnvMapCube(roughness, vec4(uEnvironmentTransform * vec4(R,1.0)).xyz);
    #endif
    // vec3 prefilteredColor = prefilterEnvMapCube(roughness, vec4(uEnvironmentTransform * vec4(R,1.0)).xyz);
    
    float factor = clamp(1.0 + dot(R, frontNormal), 0.0, 1.0);
    prefilteredColor *= factor * factor;
    return prefilteredColor;
}
// Analytical approximation of the DFG LUT, one half of the
// split-sum approximation used in indirect specular lighting.
// via 'environmentBRDF' from "Physically Based Shading on Mobile"
// https://www.unrealengine.com/blog/physically-based-shading-on-mobile - environmentBRDF for GGX on mobile
vec2 integrateSpecularBRDF( const in float dotNV, const in float roughness ) {
	const vec4 c0 = vec4( - 1, - 0.0275, - 0.572, 0.022 );

	const vec4 c1 = vec4( 1, 0.0425, 1.04, - 0.04 );

	vec4 r = roughness * c0 + c1;

	float a004 = min( r.x * r.x, exp2( - 9.28 * dotNV ) ) * r.x + r.y;

	return vec2( -1.04, 1.04 ) * a004 + r.zw;

}

vec3 integrateBRDF(const in vec3 specular, const in float roughness, const in float NoV, const in float f90) {
    // vec4 rgba = texture2D(sIntegrateBRDF, vec2(NoV, roughness));
    // float b = (rgba[3] * 65280.0 + rgba[2] * 255.0);
    // float a = (rgba[1] * 65280.0 + rgba[0] * 255.0);
    vec2 brdf=integrateSpecularBRDF(NoV,roughness);
    // const float div = 1.0 / 65535.0;
    // return (specular * a + b * f90) * div;
    return (specular * brdf.x + brdf.y * f90);
}
// vec3 integrateBRDF(const in vec3 specular, const in float roughness, const in float NoV, const in float f90) {
//     vec4 rgba = texture2D(sIntegrateBRDF, vec2(NoV, roughness));
//     float b = (rgba[3] * 65280.0 + rgba[2] * 255.0);
//     float a = (rgba[1] * 65280.0 + rgba[0] * 255.0);
//     const float div = 1.0 / 65535.0;
//     return (specular * a + b * f90) * div;
// }

vec3 computeIBLSpecularUE4(const in vec3 normal, const in vec3 eyeVector, const in float roughness, const in vec3 specular, const in vec3 frontNormal, const in float f90) {
    float NoV = dot(normal, eyeVector);
    return getPrefilteredEnvMapColor(normal, eyeVector, roughness, frontNormal) * integrateBRDF(specular, roughness, NoV, f90);
}
#endif
float getMaterialOpacity() {
    float alpha = 1.0;
    #ifdef USE_ALPHAMAP
        vec2 uv0=getCurrentUv(alphaMap_uv);
             uv0=(alphaMapTransform*vec3(uv0,1.0)).xy;
             alpha = (texture2D(alphaMap,uv0).r);
    #endif
            alpha=alpha*opacity;
    // if (uOpacityInvert == 1) alpha = 1.0 - alpha;
           return alpha;
}
float specularOcclusion(const in int occlude, const in float ao, const in vec3 normal, const in vec3 eyeVector) {
    if (occlude == 0) return 1.0;
    
    float d = dot(normal, eyeVector) + ao;
    return clamp((d * d) - 1.0 + ao, 0.0, 1.0);
}
#ifdef USE_NORMALMAP
    uniform sampler2D normalMap;
    uniform vec2 normalScale;
#endif
#ifdef USE_BUMPMAP
    uniform sampler2D bumpMap;
    uniform float bumpScale;
    // Bump Mapping Unparametrized Surfaces on the GPU by Morten S. Mikkelsen
    // http://api.unrealengine.com/attachments/Engine/Rendering/LightingAndShadows/BumpMappingWithoutTangentSpace/mm_sfgrad_bump.pdf
    // Evaluate the derivative of the height w.r.t. screen-space using forward differencing (listing 2)
    vec2 dHdxy_fwd() {
        vec2 dSTdx = dFdx( vTexCoord1 );
        vec2 dSTdy = dFdy( vTexCoord1 );
        vec2 uv0=getCurrentUv(bumpMap_uv);
             uv0=(bumpMapTransform*vec3(uv0,1.0)).xy;
        float Hll = bumpScale * texture2D( bumpMap,uv0).x;
        float dBx = bumpScale * texture2D( bumpMap,uv0+ dSTdx ).x - Hll;
        float dBy = bumpScale * texture2D( bumpMap,uv0+ dSTdy ).x - Hll;
            return vec2( dBx, dBy );
    }
    vec3 perturbNormalArb( vec3 surf_pos, vec3 surf_norm, vec2 dHdxy ) {
        // Workaround for Adreno 3XX dFd*( vec3 ) bug. See #9988
        vec3 vSigmaX = vec3( dFdx( surf_pos.x ), dFdx( surf_pos.y ), dFdx( surf_pos.z ) );
        vec3 vSigmaY = vec3( dFdy( surf_pos.x ), dFdy( surf_pos.y ), dFdy( surf_pos.z ) );
        vec3 vN = surf_norm;        // normalized

        vec3 R1 = cross( vSigmaY, vN );
        vec3 R2 = cross( vN, vSigmaX );

        float fDet = dot( vSigmaX, R1 );

        // fDet *= ( float( gl_FrontFacing ) * 2.0 - 1.0 );

        vec3 vGrad = sign( fDet ) * ( dHdxy.x * R1 + dHdxy.y * R2 );
        return normalize( abs( fDet ) * surf_norm - vGrad );

    }

#endif
#ifdef USE_NORMALMAP
vec3 getMaterialNormal(){
        //采用切线空间法线
        vec2 uv0=getCurrentUv(normalMap_uv);
        uv0=(normalMapTransform*vec3(uv0,1.0)).xy;
        vec3 mapN = texture2D( normalMap,uv0).xyz * 2.0 - 1.0;
        mapN.y = uNormalMapFlipY == 1 ? -mapN.y : mapN.y;
        mapN.xy *= normalScale;
        vec3 normal = normalize(mapN);
    return normal;
}
       // Per-Pixel Tangent Space Normal Mapping
        // http://hacksoflife.blogspot.ch/2009/11/per-pixel-tangent-space-normal-mapping.html
        vec3 perturbNormal2Arb( vec3 eye_pos, vec3 surf_norm ) {
            // Workaround for Adreno 3XX dFd*( vec3 ) bug. See #9988
            vec3 q0 = vec3( dFdx( eye_pos.x ), dFdx( eye_pos.y ), dFdx( eye_pos.z ) );
            vec3 q1 = vec3( dFdy( eye_pos.x ), dFdy( eye_pos.y ), dFdy( eye_pos.z ) );
            vec2 st0 = dFdx( vTexCoord1.st );
            vec2 st1 = dFdy( vTexCoord1.st );

            float scale = sign( st1.t * st0.s - st0.t * st1.s ); // we do not care about the magnitude

            vec3 S = normalize( ( q0 * st1.t - q1 * st0.t ) * scale );
            vec3 T = normalize( ( - q0 * st1.s + q1 * st0.s ) * scale );
            vec3 N = normalize( surf_norm );
            mat3 tsn = mat3( S, T, N );
            vec2 uv0=getCurrentUv(normalMap_uv);
                 uv0=(normalMapTransform*vec3(uv0,1.0)).xy;
            vec3 mapN = texture2D( normalMap,uv0 ).xyz * 2.0 - 1.0;
                 mapN.y = uNormalMapFlipY == 1 ? -mapN.y : mapN.y;
                 mapN.xy *= normalScale;
                 return normalize( tsn * mapN );

        }
#endif
//灯光计算相关
vec4 precomputeGGX(const in vec3 normal, const in vec3 eyeVector, const in float roughness) {
    float NoV =  clamp(dot(normal, eyeVector), 0., 1.);
    float r2 = roughness * roughness;
    return vec4(r2, r2 * r2, NoV, NoV * (1.0 - r2));
}

float D_GGX(const vec4 precomputeGGX, const float NoH) {
    float a2 = precomputeGGX.y;
    float c =  clamp(NoH * a2 - NoH,0.0,1.0);
    float d = (c) * NoH + 1.0;
    return a2 / (3.141593 * d * d);
}
float V_SmithCorrelated(const vec4 precomputeGGX, const float NoL) {
    float a = precomputeGGX.x;
    float smithV = NoL * (precomputeGGX.w + a);
    float smithL = precomputeGGX.z * (NoL * (1.0 - a) + a);
    return 0.5 / (smithV + smithL);
    
}
vec3 F_Schlick(const vec3 f0, const float f90, const in float VoH) {
    float VoH5 = pow(1.0 - VoH, 5.0);
    return f90 * VoH5 + (1.0 - VoH5) * f0;
}

float F_Schlick(const float f0, const float f90, const in float VoH) {
    return f0 + (f90 - f0) * pow(1.0 - VoH, 5.0);
}
vec3 specularLobe(const vec4 precomputeGGX, const vec3 normal, const vec3 eyeVector, const vec3 eyeLightDir, const vec3 specular, const float NoL, const float f90) {
    vec3 H = normalize(eyeVector + eyeLightDir);
    float NoH =  clamp(dot(normal, H), 0., 1.);
    float VoH =  clamp(dot(eyeLightDir, H), 0., 1.);
    
    float D = D_GGX(precomputeGGX,NoH);
    float V = V_SmithCorrelated(precomputeGGX, NoL);
    vec3 F = F_Schlick(specular, f90, VoH);
    
    return (D * V * 3.141593) * F;
}
void computeLightLambertGGX(
const in vec3 normal,
const in vec3 eyeVector,
const in float NoL,
const in vec4 precomputeGGX,

const in vec3 diffuse,
const in vec3 specular,

const in float attenuation,
const in vec3 lightColor,
const in vec3 eyeLightDir,
const in float f90,

out vec3 diffuseOut,
out vec3 specularOut,
out bool lighted) {
        lighted = NoL > 0.0;
        if (lighted == false) {
             specularOut = diffuseOut = vec3(0.0);
             return;
            }
        vec3 colorAttenuate = attenuation * NoL * lightColor;
        specularOut = colorAttenuate * specularLobe(precomputeGGX, normal, eyeVector, eyeLightDir, specular, NoL, f90);
        diffuseOut = colorAttenuate * diffuse;

}
vec3 getLightLambertDiffuse(
    const in float NoL,
    const in vec3 diffuse,
    const in float attenuation,
    const in vec3 lightColor){
    bool lighted = NoL > 0.1;
    if (lighted == false) {
        return vec3(0.0);
    }
    vec3 colorAttenuate = attenuation * NoL * lightColor;
    return colorAttenuate * diffuse;
}
vec3 getLightLambertSpecular(
    const in vec3 normal,
    const in vec3 eyeVector,
    const in float NoL,
    const in vec4 precomputeGGX,
    const in vec3 specular,
    const in float attenuation,
    const in vec3 lightColor,
    const in vec3 eyeLightDir,
    const in float f90){
    bool lighted = NoL > 0.1;
    if (lighted == false) {
        return vec3(0.0);
    }
    
    vec3 colorAttenuate = attenuation * NoL * lightColor;
    return colorAttenuate * specularLobe(precomputeGGX, normal, eyeVector, eyeLightDir, specular, NoL, f90);

}

#if 0 > 0
    float getSpotDotNL(vec3 eyeLightDir,vec3 normal){
        float dotNL = dot(eyeLightDir, normal);
        return dotNL;
    }

    vec3 getSpotEyeLightDir(vec3 viewVertex,SpotLight spotLight){
        vec3 eyeLightDir = -viewVertex+spotLight.position ;
        float dist = length(eyeLightDir);
        eyeLightDir = dist > 0.0 ? eyeLightDir / dist : vec3( 0.0, 1.0, 0.0 );
        return eyeLightDir;
    }
    float getSpotAttenuation(vec3 normal,vec3 viewVertex,SpotLight spotLight) {
        float attenuation=0.0;
        vec3 lVector = spotLight.position - viewVertex;
        vec3 direction = normalize( lVector );
        float lightDistance = length( lVector );
        float angleCos = dot(direction, spotLight.direction );
        if ( angleCos > spotLight.coneCos ) {
            float spotEffect = smoothstep( spotLight.coneCos, spotLight.penumbraCos, angleCos );
            attenuation= spotEffect * punctualLightIntensityToIrradianceFactor( lightDistance, spotLight.distance, spotLight.decay );
        } else {
            attenuation=0.0;

        }
        return attenuation;
    }
void precomputeSpot(
SpotLight spotLight,
vec3 normal,
vec3 viewVertex,
vec3 lightViewPosition,
out float attenuation,
out vec3 eyeLightDir,
out float dotNL) {
    
    eyeLightDir = lightViewPosition - viewVertex;
    float dist = length(eyeLightDir);
    eyeLightDir = dist > 0.0 ? eyeLightDir / dist : vec3( 0.0, 1.0, 0.0 );
    dotNL = dot(eyeLightDir, normal);
    attenuation = getSpotAttenuation(normal,viewVertex, spotLight);
}
#endif
vec2 cubeToUV( vec3 v, float texelSizeY ) {
    // Number of texels to avoid at the edge of each square
    vec3 absV = abs( v );

    // Intersect unit cube

    float scaleToCube = 1.0 / max( absV.x, max( absV.y, absV.z ) );
    absV *= scaleToCube;

    // Apply scale to avoid seams

    // two texels less per square (one texel will do for NEAREST)
    v *= scaleToCube * ( 1.0 - 2.0 * texelSizeY );
    // Unwrap
    // space: -1 ... 1 range for each square
    //
    // #X##     dim    := ( 4 , 2 )
    //  # #     center := ( 1 , 1 )
    vec2 planar = v.xy;
    float almostATexel = 1.5 * texelSizeY;
    float almostOne = 1.0 - almostATexel;
    if ( absV.z >= almostOne ) {
        if ( v.z > 0.0 )planar.x = 4.0 - v.x;
    } else if ( absV.x >= almostOne ) {
        float signX = sign( v.x );
        planar.x = v.z * signX + 2.0 * signX;
    } else if ( absV.y >= almostOne ) {
        float signY = sign( v.y );
        planar.x = v.x + 2.0 * signY + 2.0;
        planar.y = v.z * signY - 2.0;
    }
    // Transform to UV space

    // scale := 0.5 / dim
    // translate := ( center + 0.5 ) / dim
    return vec2( 0.125, 0.25 ) * planar + vec2( 0.375, 0.75 );
}
/*
#if 0 > 0
    // TODO (abelnation): create uniforms for area light shadows

#endif
*/
float unpackRGBAToDepth( const in vec4 v ) {
    return dot( v, UnpackFactors );
}
vec2 unpack2HalfToRGBA( vec4 v ) {
    return vec2( v.x + ( v.y / 255.0 ), v.z + ( v.w / 255.0 ) );
}

#ifdef USE_SHADOWMAP
    #if 0 > 0
            uniform sampler2D directionalShadowMap[ 0 ];
    #endif
    #if 0 > 0
        uniform sampler2D spotShadowMap[ 0 ];
    #endif
    #if 0 > 0
            uniform sampler2D pointShadowMap[ 0 ];
    #endif

    float decodeFloatRGBA(const in vec4 rgba) {
         return dot(rgba, vec4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 16581375.0));
    }
    float getSingleFloatFromTex(const in sampler2D depths, const in vec2 uv){
        return decodeFloatRGBA(texture2D(depths, uv));
    }
    float texture2DCompare( sampler2D depths, vec2 uv, float compare ) {
            return step( compare, unpackRGBAToDepth( texture2D( depths, uv ) ) );
        }   
    // TODO could be in a random.glsl file
    // https://github.com/EpicGames/UnrealEngine/blob/release/Engine/Shaders/Private/Random.ush#L27
    float shadowInterleavedGradientNoise(const in vec2 fragCoord, const in float frameMod) {
            vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
            return fract(magic.z * fract(dot(fragCoord.xy + frameMod * vec2(47.0, 17.0) * 0.695, magic.xy)));
        }

    float texture2DCompare2D(
        vec2 shadowDepthRange,
        const in sampler2D depths,
        const in vec2 uv,
        const in float compare,
        const in vec4 clampDimension){
        float depth = getSingleFloatFromTex(depths, clamp(uv, clampDimension.xy, clampDimension.zw));
            //   depth= (depth-shadowDepthRange.x)/(shadowDepthRange.y-shadowDepthRange.x);
        return compare - depth;
        }
    float readDepth( sampler2D depthSampler, vec2 coord ) {
            return texture2D( depthSampler, coord ).x; 
    }
    float texture2DShadowLerp2(
        vec2 shadowDepthRange,
        sampler2D depths,
        vec2 size,
        vec2 uv,
        float compare,
        vec4 clampDimension,
        float jitter) {
        vec2 centroidCoord = uv /size.xy;
        if (jitter > 0.0){
            centroidCoord += shadowInterleavedGradientNoise(gl_FragCoord.xy, jitter);
        }
        centroidCoord = centroidCoord + 0.5;
        vec2 f = fract(centroidCoord);
        vec2 centroidUV = floor(centroidCoord) * size.xy;
        
        vec4 fetches;
        const vec2 shift  = vec2(1.0, 0.0);
       
        fetches.x = texture2DCompare2D( shadowDepthRange,depths, centroidUV + size.xy * shift.yy, compare, clampDimension);
        fetches.y = texture2DCompare2D( shadowDepthRange,depths, centroidUV + size.xy * shift.yx, compare, clampDimension);
        fetches.z = texture2DCompare2D( shadowDepthRange,depths, centroidUV + size.xy * shift.xy, compare, clampDimension);
        fetches.w = texture2DCompare2D( shadowDepthRange,depths, centroidUV + size.xy * shift.xx, compare, clampDimension);  
        vec4 st = step(fetches, vec4(0.0));
        
        float a = mix(st.x, st.y, f.y);
        float b = mix(st.z, st.w, f.y);
        return mix(a, b, f.x);
    }
    float getShadowPCF(
        vec2 shadowDepthRange,
        sampler2D depths,
        vec2 size,
        vec2 uv,
        float compare,
        vec2 biasPCF,
        vec4 clampDimension,
        float jitter) {
            float res = 0.0;
            res += texture2DShadowLerp2(  shadowDepthRange,depths, size, uv + biasPCF, compare, clampDimension ,jitter);
            #if defined(_PCFx1)
            #else
                float dx0 = -size.x;
                float dy0 = -size.y;
                float dx1 = size.x;
                float dy1 = size.y;
                #define TSF(o1,o2) texture2DShadowLerp2(shadowDepthRange,depths, size, uv + vec2(o1, o2) + biasPCF, compare, clampDimension, jitter)
                 res += TSF(dx0, dx0);
                res += TSF(dx0, .0);
                res += TSF(dx0, dx1);
                #if defined(_PCFx4)
                        res /=4.0;
                #elif defined(_PCFx9)
                    res += TSF(.0, dx0);
                    res += TSF(.0, dx1);
                    res += TSF(dx1, dx0);
                    res += TSF(dx1, .0);
                    res += TSF(dx1, dx1);
                    res /=9.0;
                #elif defined(_PCFx25)
                    float dx02 = 2.0*dx0;
                    float dy02 = 2.0*dy0;
                    float dx2 = 2.0*dx1;
                    float dy2 = 2.0*dy1;
                    // complete row above
                    res += TSF(dx0, dx02);
                    res += TSF(dx0, dx2);
                    res += TSF(.0, dx02);
                    res += TSF(.0, dx2);
                    res += TSF(dx1, dx02);
                    res += TSF(dx1, dx2);
                    // two new col
                    res += TSF(dx02, dx02);
                    res += TSF(dx02, dx0);
                    res += TSF(dx02, .0);
                    res += TSF(dx02, dx1);
                    res += TSF(dx02, dx2);
                    res += TSF(dx2, dx02);
                    res += TSF(dx2, dx0);
                    res += TSF(dx2, .0);
                    res += TSF(dx2, dx1);
                    res += TSF(dx2, dx2);
                    res/=25.0;
                #endif
            #endif
        return res;
    }
float shadowReceive( 
    bool lighted,
    vec3 normalWorld,
    vec3 vertexWorld,
    sampler2D shadowTexture,
    vec2 shadowSize,
    vec3 shadowProjection,
    vec4 shadowViewRight,
    vec4 shadowViewUp,
    vec4 shadowViewLook,
    vec2 shadowDepthRange,
    float shadowBias,
    float jitter) {
    bool earlyOut = false;
    float shadow = 1.0;
    if (!lighted) {
        shadow = 0.0;
        // earlyOut = true;
    }
    if (shadowDepthRange.x == shadowDepthRange.y) {
        earlyOut = true;
    }
    
    vec4 shadowVertexEye;
    vec4 shadowNormalEye;
    float shadowReceiverZ = 0.0;
    vec4 shadowVertexProjected;
    vec2 shadowUV;
    float N_Dot_L;
    float invDepthRange;
    if (!earlyOut) {
        
        shadowVertexEye.x = dot(shadowViewRight.xyz, vertexWorld.xyz) + shadowViewRight.w;
        shadowVertexEye.y = dot(shadowViewUp.xyz, vertexWorld.xyz) + shadowViewUp.w;
        shadowVertexEye.z = dot(shadowViewLook.xyz, vertexWorld.xyz) + shadowViewLook.w;
        shadowVertexEye.w = 1.0;
        
        shadowNormalEye.z = dot(shadowViewLook.xyz, normalWorld.xyz);
        
        N_Dot_L = shadowNormalEye.z;
        
        if (!earlyOut) {
            
            invDepthRange = 1.0 / (shadowDepthRange.y - shadowDepthRange.x);
            
            vec4 viewShadow = shadowVertexEye;
            
            if (shadowProjection.z == 0.0){
                
                shadowVertexProjected.x = shadowProjection.x * viewShadow.x;
                shadowVertexProjected.y = shadowProjection.y * viewShadow.y;
                
                shadowVertexProjected.z = - viewShadow.z - (2.0 * shadowDepthRange.x * viewShadow.w);
                shadowVertexProjected.w = - viewShadow.z;
                
            }
            else{
                
                float nfNeg = 1.0 / (shadowDepthRange.x - shadowDepthRange.y);
                float nfPos = (shadowDepthRange.x + shadowDepthRange.y)*nfNeg;
                
                shadowVertexProjected.x = viewShadow.x / shadowProjection.x;
                shadowVertexProjected.y = viewShadow.y / shadowProjection.y;
                
                shadowVertexProjected.z = 2.0 * nfNeg* viewShadow.z + nfPos * viewShadow.w;
                shadowVertexProjected.w = viewShadow.w;
                
            }
            
            if (shadowVertexProjected.w < 0.0) {
                earlyOut = true;
            }
            
        }
        
        if (!earlyOut) {
            
            shadowUV.xy = shadowVertexProjected.xy / shadowVertexProjected.w;
            shadowUV.xy = shadowUV.xy * 0.5 + 0.5;
            
            if (any(bvec4 ( shadowUV.x > 1., shadowUV.x < 0., shadowUV.y > 1., shadowUV.y < 0.))) {
                earlyOut = true;
            }
            
            shadowReceiverZ = - shadowVertexEye.z;
            shadowReceiverZ =  (shadowReceiverZ - shadowDepthRange.x) * invDepthRange;
            
            if(shadowReceiverZ < 0.0) {
                earlyOut = true;
            }
            
        }
    }
    
    vec2 shadowBiasPCF = vec2 (0.);
    
    shadowBiasPCF.x = clamp(dFdx(shadowReceiverZ) * shadowSize.x, -1.0, 1.0 );
    shadowBiasPCF.y = clamp(dFdy(shadowReceiverZ) * shadowSize.y, -1.0, 1.0 );
    
    vec4 clampDimension;
    
    clampDimension = vec4(0.0, 0.0, 1.0, 1.0);
    
    if (earlyOut) {
        
        } else {
        
        float depthBias = 0.05 * sqrt( 1.0 - N_Dot_L * N_Dot_L) / clamp(N_Dot_L, 0.0005, 1.0);
        
        depthBias = clamp(depthBias, 0.00005, 2.0 * shadowBias);
        
        shadowReceiverZ = clamp(shadowReceiverZ, 0.0, 1.0 -depthBias) - depthBias;
        // return shadowReceiverZ;
        // return getSingleFloatFromTex(shadowTexture,shadowUV);
        float res = getShadowPCF(
            shadowDepthRange,
        shadowTexture,
        shadowSize,
        shadowUV,
        shadowReceiverZ,
        shadowBiasPCF,
        clampDimension,
        jitter);
        
        if (lighted) shadow = res;
    }
    
    return shadow;

        
    }
    float getPointShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {
            vec2 texelSize = vec2( 1.0 ) / ( shadowMapSize * vec2( 4.0, 2.0 ) );
            // for point lights, the uniform @vShadowCoord is re-purposed to hold
            // the vector from the light to the world-space position of the fragment.
            vec3 lightToPosition = shadowCoord.xyz;
            // dp = normalized distance from light to fragment position
            float dp = ( length( lightToPosition ) - shadowCameraNear ) / ( shadowCameraFar - shadowCameraNear ); // need to clamp?
            dp += shadowBias;
            // bd3D = base direction 3D
            vec3 bd3D = normalize( lightToPosition );
            #if defined( SHADOWMAP_TYPE_PCF ) || defined( SHADOWMAP_TYPE_PCF_SOFT ) || defined( SHADOWMAP_TYPE_VSM )
                vec2 offset = vec2( - 1, 1 ) * shadowRadius * texelSize.y;
                return (
                    texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyy, texelSize.y ), dp ) +
                    texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyy, texelSize.y ), dp ) +
                    texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyx, texelSize.y ), dp ) +
                    texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyx, texelSize.y ), dp ) +
                    texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp ) +
                    texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxy, texelSize.y ), dp ) +
                    texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxy, texelSize.y ), dp ) +
                    texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxx, texelSize.y ), dp ) +
                    texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxx, texelSize.y ), dp )
                ) * ( 1.0 / 9.0 );

            #else // no percentage-closer filtering

                return texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp );

            #endif

        }

#endif

#if 0 > 0
    // directLight is an out parameter as having it as a return value caused compiler errors on some devices
    float getPointDirectLightIrradiance( const in PointLight pointLight, vec3 viewVertex) {
        vec3 lVector = pointLight.position - viewVertex;
        float lightDistance = length( lVector );
        float attenuation= punctualLightIntensityToIrradianceFactor( lightDistance, pointLight.distance, pointLight.decay );
        return attenuation;

    }

#endif

#ifdef USE_CLEARCOAT
    vec3 beerLambert(const float NoV, const float NoL, const vec3 tint, const float d) {
        
        return exp(tint * -(d * ((NoL + NoV) / max(NoL * NoV, 1e-3))));
    }
    vec3 getClearCoatAbsorbtion(const in float NoV, const in float NoL, const in float clearCoatFactor) {
        // return mix(vec3(1.0), beerLambert(NoV, NoL, 1.0-sRGBToLinear(uClearCoatTint.rgb), uClearCoatThickness), clearCoatFactor);
        return mix(vec3(1.0), beerLambert(NoV, NoL, 1.0-uClearCoatTint.rgb, uClearCoatThickness), clearCoatFactor);
    }

    vec3 getLightLambertGGXClearCoatSpecular(
        const in float ccNoV,
        const in vec3 normal,
        const in vec3 eyeVector,
        const in float dotNL,
        const in vec4 precomputeGGX,
        const in float attenuation,
        const in vec3 lightColor,
        const in vec3 eyeLightDir,
        const in float clearCoatFactor){
            float _clearCoatFactor=clearCoatFactor;
        if(clearCoatFactor>1.){
            _clearCoatFactor=1.0;
        }
            vec3 clearCoatSpecular;
            if (dotNL <= 0.0) {
                clearCoatSpecular = vec3(0.0);
            
                return clearCoatSpecular;
            }
            
            float ccNoL =  clamp(dot(normal, -refract(eyeLightDir, normal, 1.0 / uClearCoatIor)), 0., 1.); 
            vec3 H = normalize(eyeVector + eyeLightDir);
            float NoH =  clamp(dot(normal, H), 0., 1.);
            float VoH =  clamp(dot(eyeLightDir, H), 0., 1.);
            
            float D = D_GGX(precomputeGGX, NoH);
            float V = V_SmithCorrelated(precomputeGGX, ccNoL);
            float F = F_Schlick(uClearCoatF0, 1.0, VoH);
            
            clearCoatSpecular = (attenuation * dotNL * _clearCoatFactor * D * V * 3.141593 * F) * lightColor;
        return clearCoatSpecular;
    }
    vec3 getLightLambertGGXClearCoatAttenuation(
        const in float ccNoV,
        const in vec3 normal,
        const in vec3 eyeVector,
        const in float dotNL,
        const in vec3 eyeLightDir,
        const in float clearCoatFactor 
    ){
        float _clearCoatFactor=clearCoatFactor;
        if(clearCoatFactor>1.){
            _clearCoatFactor=1.0;
        }
    vec3 clearCoatAttenuation;
        if (dotNL <= 0.0) {
            clearCoatAttenuation = vec3(0.0);
            return clearCoatAttenuation;
        }   
        float ccNoL =  clamp(dot(normal, -refract(eyeLightDir, normal, 1.0 / uClearCoatIor)), 0., 1.);
        vec3 clearCoatAbsorption = getClearCoatAbsorbtion(ccNoV, ccNoL, _clearCoatFactor);
        vec3 H = normalize(eyeVector + eyeLightDir);
        float VoH =  clamp(dot(eyeLightDir, H), 0., 1.);
        float F = F_Schlick(uClearCoatF0, 1.0, VoH);
        clearCoatAttenuation = (1.0 - F * _clearCoatFactor) * clearCoatAbsorption;
        return clearCoatAttenuation;
    }
#endif
float getSubMaterialTranslucency() {
    return uSubsurfaceTranslucencyFactor;
}
vec3 computeLightSSS(
     float dotNL,
     float attenuation,
     float thicknessFactor,
     vec3 translucencyColor,
     float translucencyFactor,
     float shadowDistance,
     vec3 diffuse,
     vec3 lightColor) {
       // http://blog.stevemcauley.com/2011/12/03/energy-conserving-wrapped-diffuse/
       // float scatter = 0.5;
       // float wrap = saturate((dotNL + scatter) / ((1.0 + scatter) * (1.0 + scatter)));
       // https://github.com/iryoku/separable-sss/blob/master/SeparableSSS.h#L362
       float wrap = saturate(0.3 - dotNL);
       float thickness = max(0.0, (1.0-shadowDistance) / max(0.001, thicknessFactor));
       // http://www.crytek.com/download/2014_03_25_CRYENGINE_GDC_Schultz.pdf
       // skin approximation vec3(0.98, 0.3, 0.2)
       float finalAttenuation = translucencyFactor * attenuation;
       return finalAttenuation * lightColor * diffuse * exp(-thickness / max(translucencyColor, vec3(0.001)));
} 
float checkerboard(const in vec2 uv, const in vec4 halton) {
      return mod(step(halton.z, 0.0) + floor(uv.x) + floor(uv.y), 2.0);
}
// http://en.wikibooks.org/wiki/GLSL_Programming/Applying_Matrix_Transformations
vec3 inverseTransformDirection( in vec3 dir, in mat4 matrix ) {

	return normalize( ( vec4( dir, 0.0 ) * matrix ).xyz );

}
void main(){
     vec3 diffuse = vec3(0.0);
    vec3 specular = vec3(0.0);
    vec3 eyeVector = -normalize(vViewPosition.xyz);
    vec3 frontNormal = normalize(gl_FrontFacing ? vViewNormal : -vViewNormal);
       frontNormal = inverseTransformDirection(frontNormal, modelViewMatrix );
       eyeVector = inverseTransformDirection(eyeVector, modelViewMatrix );
    // frontNormal = inverseTransformDirection(frontNormal, viewMatrix );
    // eyeVector = inverseTransformDirection(eyeVector, viewMatrix );
    

    //顶点法线
    vec3 normal =frontNormal;
    //使用切线，副切线
    #ifdef USE_TANGENT
        vec4 tangent = vViewTangent;
             tangent = gl_FrontFacing ? tangent : -tangent;
        #ifdef USE_LOCALSPAE
            tangent = inverseTransformDirection(tangent, modelViewMatrix );
        #else
            tangent = inverseTransformDirection(tangent, viewMatrix );
        #endif
        vec3 bitangent = normalize(cross(normal, tangent.xyz)) * tangent.w;
    #endif
    //获取F0
    float f0 = 0.08 * getMaterialF0();
    //计算金属度
    float metal = getMaterialMetalness();
    //获取材质diffuse颜色
    vec4 mapColor=getMaterialAlbedo();
    vec3 materialDiffuse =mapColor.rgb;
    //获取透明度
    float alpha = getMaterialOpacity();
    float alphaFinal = alpha * float(1 - uOpacityAdditive)*mapColor.a;
    //alpha测试
    #ifdef ALPHATEST
       float alpha = getMaterialOpacity();
        if (alphaFinal == 0.0 || (uDrawOpaque == 1 && alphaFinal < ALPHATEST)) discard;
    #endif
    //计算高光反射分量
    vec3 materialSpecular = mix(vec3(f0), materialDiffuse, metal);
    //计算漫反射分量
    materialDiffuse *= 1.0 - metal;
    float materialF90 = clamp(50.0 * materialSpecular.g, 0.0, 1.0);
    //获取粗糙度
    float materialRoughness = getMaterialRoughness();
    //获取Ao
    float materialAO = getMaterialAO();
    //获取自发光
    vec3 materialEmit = getMaterialEmitColor();
    //获取材质法线
     vec3 materialNormal=frontNormal;
    #ifdef USE_NORMALMAP
        #ifdef USE_TANGENT
                materialNormal=getMaterialNormal();
                materialRoughness = adjustRoughnessNormalMap(materialRoughness, materialNormal);
                // materialNormal=computeNormalFromTangentSpaceNormalMap(tangent, eyeVector, materialNormal);
                materialNormal = transformNormal(uNormalMapFactor, materialNormal, tangent.xyz, bitangent, frontNormal);
        #else
            materialNormal = perturbNormal2Arb( -vViewPosition, materialNormal );
       #endif
    #elif defined( USE_BUMPMAP )

	    materialNormal = perturbNormalArb( -vViewPosition, materialNormal, dHdxy_fwd() );
    #endif
    #ifdef USE_CLEARCOAT   
        //获取材质clearCoat
        float materialClearCoat = getMaterialClearCoat();
        //获取CoatRoughness 
        float materialClearCoatRoughness = getMaterialClearCoatRoughness();
        //获取ClearCoatNormal
        vec3 materialClearCoatNormal = normal;
    #endif  
    //以上都是准备工作，获取PBR参数，
    //normal，roughness，AO，emissiveColor,F0,Diffuse,metal,alpha
    //clearCoat，ClearCoatRoughness，ClearCoatNormal，
    //计算diffuse，以及specular最后相加得到fragColor
   
    vec3 bentAnisotropicNormal = materialNormal;
    #ifdef USE_CLEARCOAT  
    float ccNoV =  clamp(dot(materialClearCoatNormal, -refract(eyeVector, materialClearCoatNormal, 1.0 / uClearCoatIor)), 0., 1.);
    float ccF0 = materialClearCoat * F_Schlick(uClearCoatF0, 1.0, ccNoV);
    vec3 ccAbsorbtion = getClearCoatAbsorbtion(ccNoV, ccNoV, materialClearCoat);
    #endif
    //diffuse环境光照
    #ifdef USE_ENVMAP
    //利用球谐系数计算环境球对于diffuse的分量
        diffuse = materialDiffuse * computeDiffuseSPH(materialNormal);
        specular = computeIBLSpecularUE4(bentAnisotropicNormal, eyeVector, materialRoughness, materialSpecular, frontNormal, materialF90);
        #ifdef USE_CLEARCOAT   
            specular = mix(specular * ccAbsorbtion, getPrefilteredEnvMapColor(materialClearCoatNormal, eyeVector, materialClearCoatRoughness, frontNormal), ccF0);
            diffuse *= ccAbsorbtion * (1.0 - ccF0);
        #endif
        diffuse *= uEnvironmentExposure;
        specular *= uEnvironmentExposure;
    #endif
    float aoSpec = 1.0;
    diffuse *= materialAO;
    aoSpec = specularOcclusion(uAOPBROccludeSpecular, materialAO, materialNormal, eyeVector);
    specular *= aoSpec;
    float attenuation, dotNL;
    bool visible =false;
    vec3 eyeLightDir;
    bool lighted;
    vec3 lightSpecular;
    vec3 lightDiffuse;
    vec4 prepGGX = precomputeGGX(materialNormal, eyeVector, max(0.045, materialRoughness));
    float shadow;
    vec3 modelNormal =  normalize(gl_FrontFacing ? vWorldNormal : -vWorldNormal);
    #ifdef USE_CLEARCOAT 
        vec4 prepGGXClearCoat = precomputeGGX(materialClearCoatNormal, eyeVector, materialClearCoatRoughness);
        vec3 ccSpecular;
        vec3 ccAttenuation;
    #endif
    #if ( 1 > 0 )
        DirectionalLight directionalLight;   
        //转换到相机空间
        //**********************************************************************
        //****************************************************************************
        for ( int i = 0; i < 1; i ++ ) {
            directionalLight = directionalLights[ i ];
            //预计算attenuation，eyeLightDir，dotNL用于计算lightSpecular，lightDiffuse
            attenuation = 1.0;
            // eyeLightDir =vec4(viewMatrix*vec4(directionalLight.direction,1.0)).xyz ;
            eyeLightDir=directionalLight.direction;
            dotNL = dot(eyeLightDir, materialNormal);
            computeLightLambertGGX(materialNormal, eyeVector, dotNL, prepGGX, materialDiffuse, materialSpecular, attenuation, sRGBToLinear(directionalLight.color), eyeLightDir, materialF90, lightDiffuse, lightSpecular, lighted);
            #ifdef USE_CLEARCOAT 
                ccAttenuation=getLightLambertGGXClearCoatAttenuation(ccNoV, materialClearCoatNormal, eyeVector, dot(materialClearCoatNormal, eyeLightDir), eyeLightDir, materialClearCoat);
                ccSpecular=getLightLambertGGXClearCoatSpecular(ccNoV, materialClearCoatNormal, eyeVector, dot(materialClearCoatNormal, eyeLightDir), prepGGXClearCoat, attenuation,sRGBToLinear(directionalLight.color), eyeLightDir, materialClearCoat);
                lightDiffuse *= ccAttenuation;
                lightSpecular = ccSpecular + lightSpecular * ccAttenuation;
            #endif
            // if(alphaFinal>=1.0){
                #if 0 > 0
                    // DirectionalLightInfo info= directionalLightInfos[i];
                    // shadow= all( bvec2( directionalLight.shadow, receiveShadow ) ) ? shadowReceive(lighted, modelNormal, vWorldPosition,directionalShadowMap[ i ],  1./directionalLight.shadowMapSize, info.lightProj, info.sunLightViewRight, info.lightViewUp, info.sunLightViewLook, info.lightNearFar, directionalLight.shadowBias,vWorldPosition.x) : 1.0;
                    // lightDiffuse*=shadow;
                    // lightSpecular*=shadow;           
                #endif
                    #ifdef USE_SSS
                      float materialTranslucency=getSubMaterialTranslucency();
                      float shadowDistance=0.0;
                     #ifdef USETRANSLUCENCYMAP
                             shadowDistance=getTranslucency();
                     #else
                             shadowDistance=0.0;
                     #endif
            lightDiffuse += computeLightSSS(
                                    dotNL, 
                                    attenuation,
                                    uSubsurfaceTranslucencyThicknessFactor,
                                    sRGBToLinear(uSubsurfaceTranslucencyColor), 
                                    materialTranslucency, 
                                    shadowDistance, 
                                    materialDiffuse.rgb, 
                                    sRGBToLinear(directionalLight.color.rgb));
                    #endif

            // } 
           
            diffuse += lightDiffuse;
            specular += lightSpecular;
        
        }
       
    #endif   
   
    #if 0 > 0
        SpotLight spotLight;
        for ( int i = 0; i < 0; i ++ ) {
            spotLight = spotLights[ i ];
             precomputeSpot(spotLight,materialNormal,vViewPosition,spotLight.position,attenuation,eyeLightDir,dotNL);
             computeLightLambertGGX(materialNormal, eyeVector, dotNL, prepGGX, materialDiffuse, materialSpecular, attenuation, sRGBToLinear(spotLight.color), eyeLightDir, materialF90, lightDiffuse, lightSpecular, lighted);
            #ifdef USE_CLEARCOAT 
                    ccAttenuation=getLightLambertGGXClearCoatAttenuation(ccNoV, materialClearCoatNormal, eyeVector, dot(materialClearCoatNormal, eyeLightDir), eyeLightDir, materialClearCoat);
                    ccSpecular=getLightLambertGGXClearCoatSpecular(ccNoV, materialClearCoatNormal, eyeVector, dot(materialClearCoatNormal, eyeLightDir), prepGGXClearCoat, attenuation,sRGBToLinear(spotLight.color), eyeLightDir, materialClearCoat);
                    lightDiffuse *= ccAttenuation;
                    lightSpecular = ccSpecular + lightSpecular * ccAttenuation;
            #endif
            //   if(alphaFinal>=1.0){
                #if 0 > 0
                    // float shadowDistance=0.0;
                    //   SpotLightInfo info= spotLightInfos[i];
                    //    shadow= all( bvec2( spotLight.shadow, receiveShadow ) ) ? shadowReceive(lighted, modelNormal, vWorldPosition,spotShadowMap[ i ],  1./spotLight.shadowMapSize, info.lightProj, info.soptLightViewRight, info.lightViewUp, info.soptLightViewLook, info.lightNearFar, spotLight.shadowBias, shadowDistance,vWorldPosition.x) : 1.0;

                    //    lightDiffuse*=shadow;
                    //    lightSpecular*=shadow;
                        // gl_FragColor = vec4(vec3(shadow),alphaFinal);
                        // return;
                    #endif
                    #ifdef USE_SSS
                     float materialTranslucency=getSubMaterialTranslucency();
                     float shadowDistance=0.0;
                     #ifdef USETRANSLUCENCYMAP
                             shadowDistance=getTranslucency();
                     #else
                             shadowDistance=0.0;
                     #endif
                      lightDiffuse += computeLightSSS(
                                    dotNL, 
                                    attenuation,
                                    uSubsurfaceTranslucencyThicknessFactor,
                                    sRGBToLinear(uSubsurfaceTranslucencyColor), 
                                    materialTranslucency, 
                                    shadowDistance, 
                                    materialDiffuse.rgb, 
                                    sRGBToLinear(spotLight.color.rgb));
                #endif
                   
            // } 
            diffuse += lightDiffuse;
            specular += lightSpecular;
    }
    #endif
    #if 0 > 0
        PointLight pointLight;
        for ( int i = 0; i < 0; i ++ ) {
                pointLight = pointLights[ i ];
                eyeLightDir =  pointLight.position - vViewPosition.xyz;
                float dist = length(eyeLightDir);
                attenuation=getPointDirectLightIrradiance( pointLight,vViewPosition.xyz);
                eyeLightDir = dist > 0.0 ? eyeLightDir / dist :  vec3( 0.0, 1.0, 0.0 );
                dotNL = dot(eyeLightDir, materialNormal);
                lightSpecular=getLightLambertSpecular(materialNormal, eyeVector, dotNL, prepGGX, materialSpecular, attenuation,sRGBToLinear( pointLight.color), eyeLightDir, materialF90);
                lightDiffuse=getLightLambertDiffuse(dotNL,materialDiffuse,attenuation,sRGBToLinear( pointLight.color));
            #ifdef USE_CLEARCOAT
                ccAttenuation=getLightLambertGGXClearCoatAttenuation(ccNoV, materialClearCoatNormal, eyeVector, dot(materialClearCoatNormal, eyeLightDir), eyeLightDir, materialClearCoat);
                ccSpecular=getLightLambertGGXClearCoatSpecular(ccNoV, materialClearCoatNormal, eyeVector, dot(materialClearCoatNormal, eyeLightDir), prepGGXClearCoat, attenuation,sRGBToLinear( pointLight.color), eyeLightDir, materialClearCoat);
                lightDiffuse *= ccAttenuation;
                lightSpecular = ccSpecular + lightSpecular * ccAttenuation;
            #endif
                diffuse += lightDiffuse;
                specular += lightSpecular; 
        }
    #endif

    vec3 frag = diffuse + specular;
    frag = uEmitMultiplicative == 1 ? frag * materialEmit : frag + materialEmit;
    #ifdef USE_LIGHTMAP
        vec2 uv0=getCurrentUv(lightMap_uv);
            uv0=(lightMapTransform*vec3(uv0,1.0)).xy;
        vec4 lightMap=texture2D(lightMap,uv0);
            lightMap=lightMapTexelToLinear(lightMap);
            lightMap=lightMap*lightMapIntensity;
            if (uMultiplyLightMap != 1){
                frag.rgb +=lightMap.rgb;
            }else{
                frag.rgb*=lightMap.rgb;
            }
    #endif 
    vec4 mapMask=getMapMask();
    #ifdef USE_SSS
        // #ifdef ISIPHONEX
            frag = (specular+diffuse)*0.5;
            frag = linearTosRGB(frag);
            gl_FragColor = vec4(frag,alphaFinal);
        // #else
        //     float _mix=checkerboard(gl_FragCoord.xy, uHalton);            
        //     frag = mix(specular, diffuse,_mix );
        //     frag = linearTosRGB(frag);
        //     gl_FragColor = vec4(frag,alphaFinal);
        // #endif
     
    #else
        frag = linearTosRGB(frag);
         #ifdef MAP_MaskMul
             gl_FragColor = vec4(frag.rgb*mapMask.rgb,alphaFinal);
         #else
            if((mapMask.r+mapMask.g+mapMask.b)>0.5){
                    gl_FragColor = vec4(mapMask.rgb,alphaFinal);
                }else{
                    gl_FragColor = vec4(frag,alphaFinal);
                }
         #endif
       
      
    #endif
    }
// #extension GL_EXT_shader_texture_lod : enable
precision highp float;
precision highp int;
#define GLSLIFY 1

// Rendering parameters
#define RAY_LENGTH_MAX		20.0
#define RAY_BOUNCE_MAX		10
#define RAY_STEP_MAX		40
#define COLOR				vec3 (0.8, 0.8, 0.9)
#define ALPHA				0.9
#define REFRACT_INDEX		vec3 (2.407, 2.426, 2.451)
#define LIGHT				vec3 (1.0, 1.0, -1.0)
#define AMBIENT				0.2
#define SPECULAR_POWER		3.0
#define SPECULAR_INTENSITY	0.5

// Math constants
#define DELTA	0.001
#define PI		3.14159265359
#ifndef saturate
#define saturate(a) clamp( a, 0.0, 1.0 )
#endif

uniform mat4 viewMatrix;
uniform vec3 cameraPosition;
uniform float toneMappingExposure;
uniform float toneMappingWhitePoint;

#define GLSLIFY 1
varying vec2 vUv;
varying vec3 Normal;
varying vec3 worldNormal;
varying vec3 worldPosition;
varying vec3 worldViewPosition;
uniform samplerCube tCubeMapNormals;
uniform sampler2D envMap;
uniform samplerCube envRefractionMap;
uniform float envMapIntensity;
uniform float tanAngleSqCone;
uniform float coneHeight;
uniform int maxBounces;
uniform mat4 modelMatrix;
uniform mat4 inverseModelMatrix;
uniform float n2;
uniform float radius;
uniform bool bDebugBounces;
uniform float rIndexDelta;
uniform float normalOffset;
uniform float squashFactor;
uniform float distanceOffset;
uniform float geometryFactor;
uniform vec3 Absorbption;
uniform vec3 colorCorrection;
uniform vec3 boostFactors;
uniform vec3 centreOffset;
uniform float opacity;
uniform float i_toneMappingExposure;
uniform float i_toneMappingWhitePoint;
uniform float colorRGBIntencity;
uniform sampler2D sphereMap;

uniform vec2 iResolution;
uniform vec3 iMouse;
uniform vec3 worldSpaceLightPos0;
uniform vec4 lightColor0; // color of light source
uniform float specularGloss;
uniform int isBlinn;

void main() {
    // Get the normal
    vec3 normal = normalize(worldNormal);
    vec3 origin = worldPosition;
    vec3 direction = normalize(worldPosition - cameraPosition);
		vec3 worldLight = normalize(worldSpaceLightPos0.xyz);

    vec3 useDir = vec3(0, 0, 0);
		if (isBlinn > 0) { // 实际代码中不要这么写
				// Blinn-Phong 光照模型
				vec3 halfDir = normalize(worldLight + direction); // 半角向量
				useDir = halfDir;
		} else {
				// Phong 光照模型
				vec3 reflectDir = normalize(reflect(-worldLight, normal)); // reflect 函数求反射角方向
				useDir = reflectDir;
		}

		// sample the texture
		vec4 color = textureCube(tCubeMapNormals, direction);

		// 漫反射
    vec3 diffuse = color.rgb * lightColor0.rgb * max(0.0, dot(normal, worldLight));

    // 高光 gloss 用来调制亮斑的大小，一般来讲，gloss越大，光斑越细小，gloss越大，光斑分布越广泛
    vec3 specular = lightColor0.rgb * pow(saturate(dot(normal, useDir)), specularGloss) * texture2D(envMap, vUv).r;

		gl_FragColor = vec4(diffuse + specular, color.a);

}
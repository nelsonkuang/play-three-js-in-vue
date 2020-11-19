precision highp float;
precision highp int;
#define GLSLIFY 1
#define HIGH_PRECISION
#define SHADER_NAME ShaderMaterial
#define RAY_BOUNCES 5
#define VERTEX_TEXTURES
#define GAMMA_FACTOR 2
#define MAX_BONES 0
#define USE_ENVMAP
#define ENVMAP_MODE_REFLECTION
#define BONE_TEXTURE
uniform mat4 modelMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat3 normalMatrix;
uniform vec3 cameraPosition;
#ifdef USE_INSTANCING
 attribute mat4 instanceMatrix;
#endif
attribute vec3 position;
attribute vec3 normal;
attribute vec2 uv;
#ifdef USE_TANGENT
	attribute vec4 tangent;
#endif
#ifdef USE_COLOR
	attribute vec3 color;
#endif
#ifdef USE_MORPHTARGETS
	attribute vec3 morphTarget0;
	attribute vec3 morphTarget1;
	attribute vec3 morphTarget2;
	attribute vec3 morphTarget3;
	#ifdef USE_MORPHNORMALS
		attribute vec3 morphNormal0;
		attribute vec3 morphNormal1;
		attribute vec3 morphNormal2;
		attribute vec3 morphNormal3;
	#else
		attribute vec3 morphTarget4;
		attribute vec3 morphTarget5;
		attribute vec3 morphTarget6;
		attribute vec3 morphTarget7;
	#endif
#endif
#ifdef USE_SKINNING
	attribute vec4 skinIndex;
	attribute vec4 skinWeight;
#endif

#define GLSLIFY 1
varying vec2 vUv;
varying vec3 Normal;
varying vec3 worldNormal;
varying vec3 vecPos;
varying vec3 viewPos;

void main() {
    vUv = uv;
    Normal =  normal;
    worldNormal = (modelMatrix * vec4(normal,0.0)).xyz;
    vecPos = (modelMatrix * vec4(position, 1.0 )).xyz;
    viewPos = (modelViewMatrix * vec4(position, 1.0 )).xyz;
    gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}
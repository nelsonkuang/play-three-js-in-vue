precision highp float;
precision highp int;
#define HIGH_PRECISION
#define SHADER_NAME ShaderMaterial
#define USE_CLEARCOAT USE_CLEARCOAT
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
varying vec2 vTexCoord1;

varying vec3 vViewNormal;
varying vec3 vWorldNormal;
varying vec3 vViewPosition;
varying vec3 vWorldPosition;
uniform mat3 worldNormalMatrix;
uniform mat3 uvTransform;
#ifdef USE_UV2
    attribute vec2 uv2;
    varying vec2 vTexCoord2;
    uniform mat3 uv2Transform;
#endif

#ifdef USE_UV3
    attribute vec2 uv3;
    varying vec2 vTexCoord3;
    uniform mat3 uv3Transform;
#endif

#ifdef USE_UV4
    attribute vec2 uv4;
    varying vec2 vTexCoord4;
    uniform mat3 uv4Transform;
#endif
#ifdef USE_COLOR
	varying vec3 vColor;
#endif

#ifdef USE_TANGENT
    varying vec4 vViewTangent;
#endif

#ifdef USE_MORPHTARGETS
	#ifndef USE_MORPHNORMALS
	uniform float morphTargetInfluences[ 8 ];
	#else
	uniform float morphTargetInfluences[ 4 ];
	#endif
#endif
#ifdef USE_SKINNING
	uniform mat4 bindMatrix;
	uniform mat4 bindMatrixInverse;
	#ifdef BONE_TEXTURE
		uniform highp sampler2D boneTexture;
		uniform int boneTextureSize;
		mat4 getBoneMatrix( const in float i ) {
			float j = i * 4.0;
			float x = mod( j, float( boneTextureSize ) );
			float y = floor( j / float( boneTextureSize ) );
			float dx = 1.0 / float( boneTextureSize );
			float dy = 1.0 / float( boneTextureSize );
			y = dy * ( y + 0.5 );
			vec4 v1 = texture2D( boneTexture, vec2( dx * ( x + 0.5 ), y ) );
			vec4 v2 = texture2D( boneTexture, vec2( dx * ( x + 1.5 ), y ) );
			vec4 v3 = texture2D( boneTexture, vec2( dx * ( x + 2.5 ), y ) );
			vec4 v4 = texture2D( boneTexture, vec2( dx * ( x + 3.5 ), y ) );
			mat4 bone = mat4( v1, v2, v3, v4 );
			return bone;
		}
	#else
		uniform mat4 boneMatrices[ MAX_BONES ];
		mat4 getBoneMatrix( const in float i ) {
			mat4 bone = boneMatrices[ int(i) ];
			return bone;
		}
	#endif
#endif
void main(){
 vec3 transformed = vec3( position );
 vec3 objectNormal = vec3( normal );
#ifdef USE_MORPHNORMALS
	objectNormal += ( morphNormal0 - normal ) * morphTargetInfluences[ 0 ];
	objectNormal += ( morphNormal1 - normal ) * morphTargetInfluences[ 1 ];
	objectNormal += ( morphNormal2 - normal ) * morphTargetInfluences[ 2 ];
	objectNormal += ( morphNormal3 - normal ) * morphTargetInfluences[ 3 ];
#endif
#ifdef USE_SKINNING
	mat4 boneMatX = getBoneMatrix( skinIndex.x );
	mat4 boneMatY = getBoneMatrix( skinIndex.y );
	mat4 boneMatZ = getBoneMatrix( skinIndex.z );
	mat4 boneMatW = getBoneMatrix( skinIndex.w );
#endif
 	
#ifdef USE_SKINNING
	mat4 skinMatrix = mat4( 0.0 );
	skinMatrix += skinWeight.x * boneMatX;
	skinMatrix += skinWeight.y * boneMatY;
	skinMatrix += skinWeight.z * boneMatZ;
	skinMatrix += skinWeight.w * boneMatW;
	skinMatrix  = bindMatrixInverse * skinMatrix * bindMatrix;
	objectNormal = vec4( skinMatrix * vec4( objectNormal, 0.0 ) ).xyz;
	#ifdef USE_TANGENT
		objectTangent = vec4( skinMatrix * vec4( objectTangent, 0.0 ) ).xyz;
	#endif
#endif
vec3 transformedNormal = objectNormal;
#ifdef USE_INSTANCING
	transformedNormal = mat3( instanceMatrix ) * transformedNormal;

#endif
 vWorldNormal=worldNormalMatrix*objectNormal;

transformedNormal = normalMatrix * transformedNormal;
// #ifdef FLIP_SIDED
// 	transformedNormal = - transformedNormal;
// #endif
#ifdef USE_TANGENT
    vec3 objectTangent = vec3( tangent.xyz );
	// vec4 transformedTangent = vec4( normalMatrix * objectTangent,tangent.w);
    // vec4 transformedTangent = vec4( normalMatrix * objectTangent,tangent.w);
    vec4 transformedTangent =vec4(( modelViewMatrix * vec4( objectTangent, 0.0 ) ).xyz,1.0) ;
      vViewTangent = transformedTangent;

#endif
 vViewNormal=transformedNormal;
#ifdef USE_MORPHTARGETS
	transformed += ( morphTarget0 - position ) * morphTargetInfluences[ 0 ];
	transformed += ( morphTarget1 - position ) * morphTargetInfluences[ 1 ];
	transformed += ( morphTarget2 - position ) * morphTargetInfluences[ 2 ];
	transformed += ( morphTarget3 - position ) * morphTargetInfluences[ 3 ];
	#ifndef USE_MORPHNORMALS
	transformed += ( morphTarget4 - position ) * morphTargetInfluences[ 4 ];
	transformed += ( morphTarget5 - position ) * morphTargetInfluences[ 5 ];
	transformed += ( morphTarget6 - position ) * morphTargetInfluences[ 6 ];
	transformed += ( morphTarget7 - position ) * morphTargetInfluences[ 7 ];
	#endif
#endif
#ifdef USE_SKINNING
	vec4 skinVertex = bindMatrix * vec4( transformed, 1.0 );
	vec4 skinned = vec4( 0.0 );
	skinned += boneMatX * skinVertex * skinWeight.x;
	skinned += boneMatY * skinVertex * skinWeight.y;
	skinned += boneMatZ * skinVertex * skinWeight.z;
	skinned += boneMatW * skinVertex * skinWeight.w;
	transformed = ( bindMatrixInverse * skinned ).xyz;
#endif
 #ifdef USE_COLOR
    vColor.xyz = color.xyz;
#endif
 vec4 worldPosition=modelMatrix*vec4( transformed,1.0 );
      vWorldPosition=worldPosition.xyz;
      vTexCoord1=( uvTransform * vec3( uv, 1. ) ).xy;

#ifdef USE_UV2
   vTexCoord2= ( uv2Transform * vec3( uv2, 1. ) ).xy;
#endif
#ifdef USE_UV3
 vTexCoord3= ( uv3Transform * vec3( uv3, 1. ) ).xy;
#endif
#ifdef USE_UV4
 vTexCoord4= ( uv4Transform * vec3( uv4, 1. ) ).xy;
#endif
 //计算相机空间法线
 vec4 mvPosition = modelViewMatrix * vec4(transformed, 1.0);
 vViewPosition=mvPosition.xyz;
 gl_Position = projectionMatrix * mvPosition;

}
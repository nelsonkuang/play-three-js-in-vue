#extension GL_EXT_shader_texture_lod : enable
precision highp float;
precision highp int;
#define HIGH_PRECISION
#define SHADER_NAME ShaderMaterial
#define RAY_BOUNCES 5
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
vec4 envMapTexelToLinear( vec4 value ) { return RGBEToLinear( value ); }
vec4 emissiveMapTexelToLinear( vec4 value ) { return GammaToLinear( value, float( GAMMA_FACTOR ) ); }
vec4 linearToOutputTexel( vec4 value ) { return LinearToGamma( value, float( GAMMA_FACTOR ) ); }

#define GLSLIFY 1
varying vec2 vUv;
varying vec3 Normal;
varying vec3 worldNormal;
varying vec3 vecPos;
varying vec3 viewPos;
uniform samplerCube tCubeMapNormals;
uniform samplerCube envMap;
uniform samplerCube envRefractionMap;
uniform float envMapIntensity;
uniform float tanAngleSqCone;
uniform float coneHeight;
uniform int maxBounces;
uniform mat4 modelMatrix;
uniform mat4 InverseModelMatrix;
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
vec4 recoverGamma( in vec4 value ) {
    return vec4( pow( value.rgb, vec3( 0.45 ) ), value.a );
}

// ToneMapping Inside
#define saturate(a) clamp( a, 0.0, 1.0 )
#define Uncharted2Helper( x ) max( ( ( x * ( 0.15 * x + 0.10 * 0.50 ) + 0.20 * 0.02 ) / ( x * ( 0.15 * x + 0.50 ) + 0.20 * 0.30 ) ) - 0.02 / 0.30, vec3( 0.0 ) )
vec3 innerUncharted2ToneMapping( vec3 color ) {
    // John Hables filmic operator from Uncharted 2 video game"
    color *= i_toneMappingExposure;
    return saturate( Uncharted2Helper( color ) / Uncharted2Helper( vec3( i_toneMappingWhitePoint ) ) );
}

// https://www.unrealengine.com/blog/physically-based-shading-on-mobile
vec3 integrateBRDF( const in vec3 viewDir, const in vec3 normal, const in vec3 specularColor, const in float roughness ) {
    float dotNV = abs( dot( normal, viewDir ) );
    const vec4 c0 = vec4( - 1, - 0.0275, - 0.572, 0.022 );
    const vec4 c1 = vec4( 1, 0.0425, 1.04, - 0.04 );
    vec4 r = roughness * c0 + c1;
    float a004 = min( r.x * r.x, exp2( - 9.28 * dotNV ) ) * r.x + r.y;
    vec2 AB = vec2( -1.04, 1.04 ) * a004 + r.zw;
    return specularColor * AB.x + AB.y;
}
    vec3 i_Uncharted2ToneMapping( vec3 color ) {
    // John Hable's filmic operator from Uncharted 2 video game
      color *= i_toneMappingExposure;
      return saturate( Uncharted2Helper( color ) / Uncharted2Helper( vec3( i_toneMappingWhitePoint ) ) );
    }
   vec4 SampleSpecularContribution(vec4 specularColor, vec3 direction ) { 
        direction = normalize(direction); 
        direction.x *= -1.0; 
        direction.z *= -1.0; 
        vec4 sampleColorRGB = envMapIntensity * envMapTexelToLinear( textureCube( envMap, direction )); 
        vec3 tempDir = normalize(vec3(0., 0., 1.) + direction); 
        float m = 2.8284271247461903 * sqrt( direction.z+1.0 ); 
        vec4 sampleColorRefraction =vec4(0.0); 
        vec3 toneMappedColor = pow(i_Uncharted2ToneMapping( sampleColorRGB.rgb ),vec3(1./1.)); 
        return vec4(toneMappedColor, 1.0); 
     } 
       vec4 SampleSpecularReflection(vec4 specularColor, vec3 direction ) { 
        // "direction = normalize(direction); 
        direction.x *= -1.0; 
        direction.z *= -1.0; 
        vec3 tempDir = normalize(vec3(0., 0., 1.) + direction); 
        vec4 sampleColorRGB = envMapIntensity * envMapTexelToLinear( textureCube( envMap, direction ) ); 
        vec4 sampleColorRefraction = vec4(0.0); 
        vec3 toneMappedColor = pow(i_Uncharted2ToneMapping(sampleColorRGB.rgb),vec3(1./1.)); 
        return vec4(toneMappedColor, 1.0); 
     } 
vec3 intersectSphere(vec3 origin, vec3 direction) {
    // Spherical deformation fit diamond model
    direction.y /= squashFactor;
    // 𝑡2⋅𝑑𝑜𝑡(𝐵,𝐵)+2𝑡⋅𝑑𝑜𝑡(𝐵,𝐴−𝐶)+𝑑𝑜𝑡(𝐴−𝐶,𝐴−𝐶)−𝑅2=0
    vec3 oc = origin - centreOffset; 
    float a = dot(direction, direction);
    float b = 2.0*dot(oc, direction);
    float c = dot(oc, oc) - radius * radius;
    float disc = b*b - 4.0 * a * c;
    if(disc > 0.0){
        disc = sqrt(disc);
        // Return the intersection point
        float t1 = (-b + disc)*geometryFactor/a;
        float t2 = (-b - disc)*geometryFactor/a;
        float t = (t1 > t2) ? t1 : t2;
        direction.y *= squashFactor;
        return vec3(origin + direction * t);
    }
    return vec3(0.0);
}

vec3 debugBounces(int count) {
    vec3 color = vec3(1.,1.,1.);
    if(count == 1)
    // Red => 1
        color = vec3(1.0,0.0,0.0);
    else if(count == 2)
    // Yellow => 2
        color = vec3(1.0,1.0,0.0);
    else if(count == 3)
    // Blue => 3
        color = vec3(0.0,0.0,1.0);
    else if(count == 4)
    // Green => 4
        color = vec3(0.0,1.0,0.0);
    else
    // Pink => Other
        color = vec3(1.0,0.0,1.0);
    if(count ==0)
    // Low Blue => 0
        color = vec3(.0,1.0,1.0);
    return color;
}

    vec3 BRDF_Specular_GGX_Environment( const in vec3 viewDir, const in vec3 normal, const in vec3 specularColor, const in float roughness ) {
      float dotNV = abs( dot( normal, viewDir ) );
      const vec4 c0 = vec4( - 1, - 0.0275, - 0.572, 0.022 );
      const vec4 c1 = vec4( 1, 0.0425, 1.04, - 0.04 );
      vec4 r = roughness * c0 + c1;
      float a004 = min( r.x * r.x, exp2( - 9.28 * dotNV ) ) * r.x + r.y;
      vec2 AB = vec2( -1.04, 1.04 ) * a004 + r.zw;
      return specularColor * AB.x + AB.y;
    }
     vec3 traceRay(vec3 origin, vec3 direction, vec3 normal) { 
       vec3 outColor = vec3(0.0); 

       // Reflect/Refract ray entering the diamond 

       const float n1 = 1.0; 
       const float epsilon = 1e-4; 
       float f0 = (2.4- n1)/(2.4 + n1); 
       f0 *= f0; 
       vec3 attenuationFactor = vec3(1.0); 
       vec3 newDirection = refract(direction, normal, n1/n2); 
       vec3 reflectedDirection = reflect(direction, normal); 
       vec3 brdfReflected = BRDF_Specular_GGX_Environment(reflectedDirection, normal, vec3(f0), 0.0); 
       vec3 brdfRefracted = BRDF_Specular_GGX_Environment(newDirection, -normal, vec3(f0), 0.0); 
       attenuationFactor *= ( vec3(1.0) - brdfRefracted); 
       outColor += SampleSpecularReflection(vec4(1.0), reflectedDirection ).rgb * brdfReflected; 
       int count = 0; 
       newDirection = (InverseModelMatrix * vec4(newDirection, 0.0)).xyz; 
       newDirection = normalize(newDirection); 
       origin = (InverseModelMatrix * vec4(origin, 1.0)).xyz; 

       // ray bounces  

       for( int i=0; i<RAY_BOUNCES; i++) {  
          vec3 intersectedPos; 
          intersectedPos = intersectSphere(origin + vec3(epsilon), newDirection); 
          vec3 dist = intersectedPos - origin; 
          vec3 d = normalize(intersectedPos - centreOffset); 

          vec3 mappedNormal = textureCube( tCubeMapNormals, d ).xyz; 
          mappedNormal = 2. * mappedNormal - 1.; 
          mappedNormal.y += normalOffset; 
          mappedNormal = normalize(mappedNormal); 
          dist = (modelMatrix * vec4(dist, 1.)).xyz; 
          float r = sqrt(dot(dist, dist)); 
        //   attenuationFactor *= exp(-r*Absorbption)*0.55; 

           // refract the ray at first intersection  

           vec3 oldOrigin = origin; 
           origin = intersectedPos - normalize(intersectedPos - centreOffset) * distanceOffset; 

          vec3 oldDir = newDirection; 
          newDirection = refract(newDirection, mappedNormal, n2/n1); 
          if( dot(newDirection, newDirection) == 0.0) { // Total Internal Reflection. Continue inside the diamond  
               newDirection = reflect(oldDir, mappedNormal); 
               if(i == RAY_BOUNCES-1 ) //If the ray got trapped even after max iterations, simply sample along the outgoing refraction!  
               { 
                  vec3 brdfReflected = BRDF_Specular_GGX_Environment(-oldDir, mappedNormal, vec3(f0), 0.0); 
                  vec3 d1 = (modelMatrix * vec4(oldDir, 0.0)).xyz; 
                       outColor += SampleSpecularContribution(vec4(1.0), d1 ).rgb * colorCorrection * attenuationFactor  * boostFactors * (vec3(1.0) - brdfReflected);
               
               } 
          } else { // Add the contribution from outgoing ray, and continue the reflected ray inside the diamond  
              vec3 brdfRefracted = BRDF_Specular_GGX_Environment(newDirection, -mappedNormal, vec3(f0), 0.0); 
              // outgoing(refracted) ray's contribution  
              vec3 d1 = (modelMatrix * vec4(newDirection, 0.0)).xyz; 
              vec3 colorG = SampleSpecularContribution(vec4(1.0), d1 ).rgb * ( vec3(1.0) - brdfRefracted); 
              vec3 dir1 = refract(oldDir, mappedNormal, (n2+rIndexDelta)/n1); 
              vec3 dir2 = refract(oldDir, mappedNormal, (n2-rIndexDelta)/n1); 
              vec3 d2 = (modelMatrix * vec4(dir1, 0.0)).xyz; 
              vec3 d3 = (modelMatrix * vec4(dir2, 0.0)).xyz; 
              vec3 colorR = SampleSpecularContribution(vec4(1.0), d2 ).rgb * ( vec3(1.0) - brdfRefracted); 
              vec3 colorB = SampleSpecularContribution(vec4(1.0), d3 ).rgb * ( vec3(1.0) - brdfRefracted); 
              outColor += vec3(colorR.r, colorG.g, colorB.b) * colorCorrection * attenuationFactor * boostFactors; 
              //outColor = oldDir; 
              //new reflected ray inside the diamond  

              newDirection = reflect(oldDir, mappedNormal); 
              vec3 brdfReflected = BRDF_Specular_GGX_Environment(newDirection, mappedNormal, vec3(f0), 0.0); 
              attenuationFactor *= brdfReflected * boostFactors; 
              count++; 
          } 
       } 
         if(false)
           outColor = debugBounces(count);
             return outColor;
     }

void main() {
    vec3 normalizedNormal = normalize(worldNormal);
    vec3 viewVector = normalize(vecPos - cameraPosition);
    vec3 color = traceRay(vecPos, viewVector, normalizedNormal);
    gl_FragColor = vec4(color.rgb, opacity);
    gl_FragColor.rgb = innerUncharted2ToneMapping(gl_FragColor.rgb);
    // gl_FragColor = textureCube(tCubeMapNormals, normalize(Normal));
}
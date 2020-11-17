varying vec3 uv2;
varying float fresnel;
uniform samplerCube tCube;
uniform samplerCube RefractTex;
uniform vec3 Color;
uniform float EnvironmentLight;
uniform float Emission;
uniform float ReflectionStrength;
uniform float frontAlpha;
void main() {
    vec3 refraction = textureCube(RefractTex, uv2).xyz;
    vec4 reflection = textureCube(tCube, uv2);
    vec3 Color = vec3(1.0, 1.0, 1.0);
    Color *= fresnel;
    vec3 multiplier = reflection.xyz * ReflectionStrength * fresnel + refraction + vec3(Emission, Emission, Emission) * (1.0 - fresnel);
    gl_FragColor =  vec4(multiplier, frontAlpha);
}

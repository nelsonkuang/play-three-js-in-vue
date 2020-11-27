varying vec3 uv2;
varying float fresnel;
uniform samplerCube tCube;
uniform samplerCube refractTex;
uniform vec3 Color;
uniform float environmentLight;
uniform float emission;
uniform float reflectionStrength;
uniform float frontAlpha;
void main() {
    vec3 refraction = textureCube(refractTex, uv2).xyz;
    vec4 reflection = textureCube(tCube, uv2);
    vec3 Color = vec3(1.0, 1.0, 1.0);
    Color *= fresnel;
    vec3 multiplier = reflection.xyz * reflectionStrength * fresnel + refraction + vec3(emission, emission, emission) * (1.0 - fresnel);
    gl_FragColor =  vec4(multiplier, frontAlpha);
}

vec3 refract2(const in vec3 i, const in vec3 n, const in float eta)
{
  float cosi = dot(i * -1.0, n);
  float cost2 = 1.0 - eta * eta * (1.0 - cosi * cosi);
  vec3 t = eta * i + n * (eta * cosi - sqrt(cost2));
  if (cost2 > 0.0) {
    return t;
  } else {
    return t * -1.0;
  }
}
uniform samplerCube tCube;
uniform samplerCube RefractTex;
uniform vec3 Color;
uniform float EnvironmentLight;
uniform float Emission;
uniform float backAlpha;
varying vec3 uv2;
void main() {
  vec3 refraction = textureCube(RefractTex, uv2).xyz;
  vec4 reflection = textureCube(tCube, uv2);
  vec3 multiplier = reflection.xyz * EnvironmentLight + vec3(Emission, Emission, Emission);
  gl_FragColor = vec4(refraction.xyz *multiplier.xyz , backAlpha);
}
varying vec3 uv2;
varying float fresnel;
uniform float cameraWorldPos[3];
void main() {
  vec3 vNormal = normalize(normal.xyz);
  vec3 vModlePosition = position.xyz;
  vec3 vertexViewDir = vec3(cameraWorldPos[0] - vModlePosition.x, cameraWorldPos[1] - vModlePosition.y, cameraWorldPos[2] - vModlePosition.z);
  vertexViewDir = vertexViewDir * 1.0;
  vertexViewDir = normalize(vertexViewDir);
  uv2 = 2.0 * vNormal * dot(vNormal, vertexViewDir) - vertexViewDir;
  uv2 = (modelMatrix * vec4(uv2, 0.0)).xyz;
  fresnel = 1.0 - dot(vNormal, vertexViewDir);
  fresnel = clamp(fresnel, 0.0, 1.0);
  float FRACT = 2.4;
  float _Power = 5.0;
  float r0 = ((1.0 - FRACT) * (1.0 - FRACT)) / ((1.0 + FRACT) * (1.0 + FRACT));
  // 菲涅尔公式
  fresnel = r0 + (1.0- r0) * pow(1.0- clamp(dot(vNormal, vertexViewDir), 0.0, 1.0), _Power);
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
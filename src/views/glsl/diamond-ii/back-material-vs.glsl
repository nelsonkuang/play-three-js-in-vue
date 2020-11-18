varying vec3 uv2;
uniform float cameraWorldPos[3];
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
void main() {
  vec3 vNormal = normal.xyz;
  vec3 vModlePosition = position.xyz;
  vec3 vertexViewDir = vec3(cameraWorldPos[0] - vModlePosition.x, cameraWorldPos[1] - vModlePosition.y, cameraWorldPos[2] - vModlePosition.z);
  vertexViewDir = vertexViewDir * -1.0;
  vertexViewDir = normalize(vertexViewDir);
  vNormal = normalize(vNormal);
  uv2 = 2.0 * vNormal * dot(vNormal, vertexViewDir) - vertexViewDir;
  uv2 = refract2(vertexViewDir, vNormal, 0.7);
  uv2 = (modelMatrix * vec4(uv2, 0.0)).xyz;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
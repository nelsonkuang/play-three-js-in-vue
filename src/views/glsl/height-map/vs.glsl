varying vec4 v_color; // 用来存储当前顶点颜色
varying vec2 v_uv; // UV
uniform float u_height; // 生成的高度
uniform float u_radius; // 半径
uniform sampler2D u_bump; // 高度图
// 插值计算
float lerp(float x, float y, float t) {
  return (1.0 - t) * x + t * y;
}
// 获得当前向量与中心点的距离
float glength(vec3 p) {
  return sqrt(p.x * p.x + p.y * p.y + p.z * p.z);
}
// 传入当前向量 需要返回的长度
vec3 setLength(vec3 p, float length) {
  vec3 c_position = p;
  float scale = length / glength(c_position);
  c_position.x *= scale;
  c_position.y *= scale;
  c_position.z *= scale;
  return c_position;
}
void main() {
  v_uv = uv; // uv
  v_color = texture2D(u_bump, uv); // 生成当前高度信息
  float c_height = v_color.r * u_height; // 生成当前的高度 当前的灰度r值 * 基础高度
  vec3 vposition = setLength(position, u_radius + c_height); // 生成新的向量 离中心距离为当前基础半径+生成的高度
  // 传递 position
  vec4 mPosition = modelViewMatrix * vec4(vposition, 1.0); 
  gl_Position = projectionMatrix * mPosition;
}
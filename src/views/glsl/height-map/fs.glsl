uniform float u_opacity; // 透明度
uniform vec3 u_color; // 基础颜色
varying vec2 v_uv; // UV
uniform sampler2D u_map; // 基础材质
void main() {
  gl_FragColor = vec4(u_color, u_opacity) * texture2D(u_map, v_uv);
}
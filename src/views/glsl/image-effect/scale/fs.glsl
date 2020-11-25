precision mediump float;
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;

void main() {
  gl_FragColor = texture2D(s_baseMap, v_texCoord);
}
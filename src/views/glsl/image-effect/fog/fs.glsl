precision mediump float;
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;
varying float fogFactor;

void main() {
  vec4 fogColor = vec4(0.0,0.4,0.6,1.0);
  vec4 finalColor = texture2D(s_baseMap, v_texCoord);
  gl_FragColor = mix(fogColor, finalColor, fogFactor ); // 根据雾的权重（fogFactor）把 fogColor 与 finalColor 做混合操作
}
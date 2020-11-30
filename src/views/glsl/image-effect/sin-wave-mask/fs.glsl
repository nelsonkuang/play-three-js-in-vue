/*
正弦波遮罩效果
*/
precision mediump float;
uniform sampler2D s_baseMap;
// uniform vec2 TexSize;
// uniform vec4 _Color; // shader property specified by users
uniform vec4 _MaskColor; // shader property specified by users
uniform float _Offset; 
// uniform float time; 

varying vec2 v_texCoord;
// 振幅（控制波浪顶端和底端的高度）
#define amplitude 0.05
// 角速度（控制波浪的周期）
#define angularVelocity 10.0
// 频率（控制波浪移动的速度）
#define frequency 15.0
// 偏距（设为 0.5 使得波浪垂直居中于屏幕）
// float offset = _Offset;

void main() {
  // sample the texture
  vec4 textureColor = texture2D(s_baseMap, v_texCoord);
  // 初相位（正值表现为向左移动，负值则表现为向右移动）
  float initialPhase = frequency * _Offset;

  // 代入正弦曲线公式计算 y 值
  // y = Asin(ωx ± φt) + k
  float y = amplitude * sin((angularVelocity * v_texCoord.x) + initialPhase) + _Offset;
  // 大于y的叠加mask color
  // if (v_texCoord.y > y) {
  //     textureColor *= _MaskColor;
  // }
  float stepFlag = step(y, v_texCoord.y);
  gl_FragColor = mix(textureColor, textureColor * _MaskColor, stepFlag);
}
/*
「抖动」是很经典的抖音的颜色偏移效果，其实这个效果实现起来还挺简单的。
另外，除了颜色偏移，可以看到还有微弱的放大效果。

这里的放大和上面类似，我们主要看一下颜色偏移。颜色偏移是对三个颜色通道进行分离，并
且给红色通道和蓝色通道添加了不同的位置偏移，代码很容易看懂。

*/
precision mediump float;
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;
uniform float time;

const float PI = 3.1415926;
void main() {
  float duration = 0.7;
  float t = mod(time, duration);

  vec4 whiteMask = vec4(1.0, 1.0, 1.0, 1.0);
  float amplitude = abs(sin(t * (PI / duration))); // 振幅

  vec4 mask = texture2D(s_baseMap, v_texCoord);

  gl_FragColor = mix(mask, whiteMask, amplitude);
}
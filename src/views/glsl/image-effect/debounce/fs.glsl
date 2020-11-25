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

void main() {
  float duration = 0.7;
  float offset = 0.02;
  float maxScale = 1.8;

  float progress = mod(time, duration) / duration; // 0~1
  vec2 offsetCoords = vec2(offset, offset) * progress;
  float scale = 1.0 + (maxScale - 1.0) * progress;

  vec2 scaleTextureCoords = vec2(0.5, 0.5) + (v_texCoord - vec2(0.5, 0.5)) / scale;
  
  vec4 maskR = texture2D(s_baseMap, scaleTextureCoords + offsetCoords);
  vec4 maskB = texture2D(s_baseMap, scaleTextureCoords - offsetCoords);
  vec4 mask = texture2D(s_baseMap, scaleTextureCoords);

  gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
}
/*
Pixelate 是像素化的意思
把屏幕分成比分辨率更小的小块，然后判断要渲染的点在哪个小块里头，对应采样那个小块的左上角的那个像素。
（也就是强行下降分辨率）:
*/
precision mediump float;
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;

void main() {
  float maxVal = max(TexSize.x, TexSize.y);
  vec2 newTexSize = vec2(maxVal, maxVal);
  const float blockSize = 8.0; // 小块大小
  vec2 intXY = vec2(v_texCoord.x * maxVal, v_texCoord.y * maxVal); // 真实点坐标
  vec2 fakeUV = floor(intXY / blockSize) * blockSize;
  vec2 uv = fakeUV / newTexSize.xy; // TexSize 相当于 resolution
  gl_FragColor = texture2D(s_baseMap, uv);
}
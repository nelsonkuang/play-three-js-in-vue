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
  const float blockSize = 16.0; // 小块大小
  vec2 intXY = vec2(v_texCoord.x * TexSize.x, v_texCoord.y * TexSize.y); // 真实点坐标
  vec2 fakeUV = floor(intXY / blockSize) * blockSize;
  vec2 uv = fakeUV / TexSize.xy;
  gl_FragColor = texture2D(s_baseMap, uv);
}
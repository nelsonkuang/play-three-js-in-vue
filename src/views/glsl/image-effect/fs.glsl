// "浮雕"图象效果是指图像的前景前向凸出背景。常见于一些纪念碑的雕刻上，
// 要实现浮雕其实非常简单。我们把图象的一个象素和左上方的象素进行求差运算，
// 并加上一个灰度。这个灰度就是表示背景颜色。这里我们设置这个插值为128 (图象RGB的值是0-255)。
// 同时,我们还应该把这两个颜色的差值转换为亮度信息.否则浮雕图像会出现彩色
precision mediump float;
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;
void main() {
  vec2 tex = v_texCoord;
  vec2 upLeftUV = vec2(tex.x-1.0/TexSize.x, tex.y-1.0/TexSize.y); // 左上角坐标
  vec4 curColor = texture2D(s_baseMap, v_texCoord); // 当前颜色
  vec4 upLeftColor = texture2D(s_baseMap, upLeftUV); // 左上角颜色
  vec4 delColor = curColor - upLeftColor; // 颜色差
  float brightness = 0.3*delColor.x + 0.59*delColor.y + 0.11*delColor.z; // 颜色差转换为亮度信息，否则出现彩色
  vec4 bkColor = vec4(0.5, 0.5, 0.5, 1.0); // 背景颜色为 128
  gl_FragColor = vec4(brightness,brightness,brightness,0.0) +bkColor;
}
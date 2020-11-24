/*
Vignette 我不知道咋翻译，他的中文是小插图？这也太奇怪了吧…… 但是总而言之，我们是可以知道 Vignette 的作用
是可以让远离中心的地方（屏幕边缘）变黑，然后整个看起来就有点像 70 年代的电影一样的东西:
这个着色器一般在静物，或者是复古的六七十年代的东西的时候渲染起来效果很好。他的原理很简单，就是远离中心的就变黑：
*/
precision mediump float;
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;

void main() {
  // 其中，intensity 的作用就是让结果曝光，如果太大会过度曝光，而太小又会太暗。在 intensity 的下一行的 0.2 可
  // 以说是扩大范围，如果这个数字越大，暗的范围就越大。最后，用输出的像素和 vignette 值相乘就可以了。
  const float intensity = 15.0;
  const float range = 0.2;
  float vig = v_texCoord.x * v_texCoord.y * intensity;
  vig = pow(vig, range);
  vec4 curColor = texture2D(s_baseMap, v_texCoord); // 当前颜色
  gl_FragColor = vec4(curColor.xyz * vig, 1.0);
}
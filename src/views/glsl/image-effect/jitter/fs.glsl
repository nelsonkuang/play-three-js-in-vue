/*
「毛刺」看上去是「撕裂 + 微弱的颜色偏移」

具体的思路是，我们让每一行像素随机偏移 -1 ~ 1 的距离（这里的 -1 ~ 1 是对于纹理坐标来说的），
但是如果整个画面都偏移比较大的值，那我们可能都看不出原来图像的样子。所以我们的逻辑是，设定一个阈值，
小于这个阈值才进行偏移，超过这个阈值则乘上一个缩小系数。
则最终呈现的效果是：绝大部分的行都会进行微小的偏移，只有少量的行会进行较大偏移。

*/
precision mediump float;
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;
uniform float time;

const float PI = 3.1415926;
float rand(float n) {
    return fract(sin(n) * 43758.5453123);
}

void main() {
  float maxJitter = 0.06;
  float duration = 0.3;
  float colorROffset = 0.01;
  float colorBOffset = -0.025;

  float t = mod(time, duration * 2.0);
  float amplitude = max(sin(t * (PI / duration)), 0.0);

  float jitter = rand(v_texCoord.y) * 2.0 - 1.0; // -1~1
  bool needOffset = abs(jitter) < maxJitter * amplitude;

  float textureX = v_texCoord.x + (needOffset ? jitter : (jitter * amplitude * 0.006));
  vec2 textureCoords = vec2(textureX, v_texCoord.y);
  
  vec4 maskR = texture2D(s_baseMap, textureCoords + vec2(colorROffset * amplitude, 0.0));
  vec4 maskB = texture2D(s_baseMap, textureCoords + vec2(colorBOffset * amplitude, 0.0));
  vec4 mask = texture2D(s_baseMap, v_texCoord);

  gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
}

/*
上面提到的像素随机偏移需要用到随机数，可惜 GLSL 里并没有内置的随机函数，所以我们需要自己实现一个。
这个 float rand(float n) 的实现看上去很神奇，它其实是来自 这里 ，江湖人称「噪声函数」。
它其实是一个伪随机函数，本质上是一个 Hash 函数。但在这里我们可以把它当成随机函数来使用，它
的返回值范围是 0 ~ 1。如果你对这个函数想了解更多的话可以看 [这里](https://xiaoiver.github.io/coding/2018/08/01/%E5%99%AA%E5%A3%B0%E7%9A%84%E8%89%BA%E6%9C%AF.html) 。
*/
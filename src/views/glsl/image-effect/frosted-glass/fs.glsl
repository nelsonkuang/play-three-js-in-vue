/*
Windows7 Aero 的酷炫毛玻璃效果，晶体的效果
rand() 可以说是一个伪随机函数吧？输入 uv ，然后通过 uv 和两个奇怪的向量点乘，并且把他们的正弦值和余弦值相加，
然后放大 51 倍（这个可以改），最后舍弃掉整数部分，返回小数点后就可以了。回到 main 可以发现，结果被进一步减小了
 - 为了不过分采样（就是离得太远）。这样就能让采样稍稍偏离原来的位置了！

当然，除此之外，其实你可以发现，假如不乘那个 51 ，然后点乘的那两个向量比较小的话 —— 就可以呈现出晶体的效果了：
*/
precision mediump float;
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;

float rand(vec2 uv) {
    float a = dot(uv, vec2(92.0, 80.0));
    float b = dot(uv, vec2(41.0, 62.0));
    float x = (sin(a) + cos(b)) * 51.0;
    return fract(x);
}

void main() {
  const float blurFactor = 0.015;
  vec2 uv = v_texCoord;
  vec2 rnd = vec2(rand(uv), rand(uv));
  uv += rnd * blurFactor;
  gl_FragColor = texture2D(s_baseMap, uv);
}
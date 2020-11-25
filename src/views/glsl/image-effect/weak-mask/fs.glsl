/*
「灵魂出窍」看上去是两个层的叠加，并且上面的那层随着时间的推移，会逐渐放大且不透明度逐渐降低。
这里也用到了放大的效果，我们这次用片段着色器来实现。

首先是放大的效果。关键点在于 weakX 和 weakY 的计算，比如 0.5 + (TextureCoordsVarying.x - 0.5) / scale 这
一句的意思是，将顶点坐标对应的纹理坐标的 x 值到纹理中点的距离，缩小一定的比例。这次我们是改变了纹理坐标，而保
持顶点坐标不变，同样达到了拉伸的效果。
然后是两层叠加的效果。通过上面的计算，我们得到了两个纹理颜色值 weakMask 和 mask， weakMask 是在 mask 的基础
上做了放大处理。
我们将两个颜色值进行叠加需要用到一个公式：最终色 = 基色 * a% + 混合色 * (1 - a%) ，这个公式来自 [混合模式中的
正常模式](https://baike.baidu.com/item/%E6%B7%B7%E5%90%88%E6%A8%A1%E5%BC%8F/6700481) 。
这个公式表明了一个不透明的层和一个半透明的层进行叠加，重叠部分的最终颜色值。因此，上面叠加的最终结果
是 mask * (1.0 - alpha) + weakMask * alpha 。

*/
precision mediump float;
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;
uniform float time;

void main() {
  float duration = 0.7;
  float maxAlpha = 0.4;
  float maxScale = 1.8;

  float progress = mod(time, duration) / duration; // 0~1
  float alpha = maxAlpha * (1.0 - progress);
  float scale = 1.0 + (maxScale - 1.0) * progress;
  
  float weakX = 0.5 + (v_texCoord.x - 0.5) / scale;
  float weakY = 0.5 + (v_texCoord.y - 0.5) / scale;

  vec2 weakTexCoord = vec2(weakX, weakY);
  vec4 weakMask = texture2D(s_baseMap, weakTexCoord);
  vec4 mask = texture2D(s_baseMap, v_texCoord);

  gl_FragColor = mix(mask, weakMask, alpha);
  
}
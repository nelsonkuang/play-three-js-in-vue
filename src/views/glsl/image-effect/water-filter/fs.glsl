/*
真正的水彩效果在shader中是比较难实现的，它需要进行中值滤波后累加等一些操作，还需要处理NPR中的笔触一类的概念。本文绕开这些概念，
只从视觉效果上能尽量模拟出水彩的画的那种感觉来。

我们知道，水彩画一个最大的特点是水彩在纸上流动扩散后会和周围的颜色搅拌在一起，另外一个特点就是水彩通常会形成一个个的色块，
过渡不像照片那样的平滑。针对这两个特点。我们可以设计这样的一个算法来模拟水彩画的效果。

我们可以采用噪声纹理的方式，既事先计算好一个nxn的随机数数组，作为纹理传递给Pixel shader，这样在Pixel Shader里我们
就能获得随机数了。得到随机数后，我们将随机数映射成纹理坐标的偏移值，就能模拟出色彩的扩散了。

接下来我们需要处理色块，我们对颜色的RGB值分别进行量化，把RGB分量由原来的8bit量化成比特数更低的值。这样颜色的过渡就会显得不那
么的平滑，而是会呈现出一定的色块效果。

通过以上两步处理后，我们得到的图像依然有非常多的细节，尤其是第一步处理中产生的很多细节噪点，很自然的我们就想到通过平滑模糊的方式
来过滤掉这些高频噪声成分。

算法设计好了，接下来看看我们如何在RenderMonkey里实现这个算法。

类似上一个效果，我们需要两个pass来完成这个算法，第一个pass叫flow pass，模拟颜色的流动和处理颜色的量化。第二个pass叫Gauss pass，
也就是前面提到的高斯模糊算法。我们的重点在第一个pass。

在模拟扩散的pass中，我们同样需要一个RenderTarget，以把结果保存在其中以便后续处理，然后还需要一个噪声纹理来产生随机数。

*/
precision mediump float;
#define GLSLIFY 1
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;

vec4 quant(vec4 _cl, float n) {
  _cl.x = floor(_cl.x*255.0/n)*n/255.0;
  _cl.y = floor(_cl.y*255.0/n)*n/255.0;
  _cl.z = floor(_cl.z*255.0/n)*n/255.0;
  return _cl; 
}

void main() {
  float maxVal = max(TexSize.x, TexSize.y);
  float _waterPower = 40.0; // _waterPower 则表示图像颜色扩散范围，取值范围在8－64之间的效果比较好。
  float _quatLevel = 5.0; // _quatLevel 用来表示对图像的量化比特数，值越小，色块越明显，比较合理的取值范围是2-6。
  vec4 noiseColor = _waterPower*texture2D(s_baseMap,v_texCoord);
  vec2 newUV =vec2(v_texCoord.x + noiseColor.x/maxVal,v_texCoord.y + noiseColor.y/maxVal);
  vec4 _fColor = texture2D(s_baseMap,newUV);
  gl_FragColor = quant(_fColor, 255.0 / pow(2.0, _quatLevel));
}
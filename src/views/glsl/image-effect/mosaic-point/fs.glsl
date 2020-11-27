// 用HLSL代码实现马赛克是非常简单的,但是同样的,我们需要一些额外的步骤,
// 第一步就是先把纹理坐标转换成图像实际大小的整数坐标.接下来,我们要把图像
// 这个坐标量化---比如马赛克块的大小是8x8象素。那么我们可以用下列方法来得
// 到马赛克后的图像采样值，假设[x.y]为图像的整数坐标：
// [x,y]mosaic = [ int(x/8)*8 , int(y/8)*8].

// 首先求出原来马赛克区域的正中心（原来是左上角）：然后计算图像采样点
// 到这个中心的距离，如果在马赛克圆内，就用区域的中心颜色，否则就用原
// 来的颜色。改良后的代码如下，这里我们把马赛克区域大小调节成32x32。这样效果更明显。

precision mediump float;
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;
vec2 mosaicSize = vec2(8,8);
void main() {
  float maxVal = max(TexSize.x, TexSize.y);
  vec2 intXY = vec2(v_texCoord.x*maxVal, v_texCoord.y*maxVal); // 把纹理坐标转换成图像实际大小的整数坐标
  vec2 XYMosaic = vec2(floor(intXY.x/mosaicSize.x)*mosaicSize.x,floor(intXY.y/mosaicSize.y)*mosaicSize.y) + 0.5*mosaicSize; // 坐标量化
  vec2 delXY = XYMosaic - intXY;
  float delL = length(delXY);
  vec2 UVMosaic = vec2(XYMosaic.x/maxVal,XYMosaic.y/maxVal); // 再缩少为纹理坐标
  vec4 _finalColor;
  if(delL < 0.5*mosaicSize.x)
    _finalColor = texture2D(s_baseMap,UVMosaic);
  else
    _finalColor = texture2D(s_baseMap,v_texCoord);
  gl_FragColor = _finalColor;  
}
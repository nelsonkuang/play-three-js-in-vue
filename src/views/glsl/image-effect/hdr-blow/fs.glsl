/*
HDR和Blow在现在主流游戏中是非常时髦的效果。

所谓HDR就是高动态范围的意思，我们知道，在普通的显示器和位图里，每通道都是8-bit，也就是说RGB分量的范围都是0-255，
这用来表示现实中的颜色显然是远远不够的，现实中的图像的动态范围远远大的多，那么如何在现有的显示设备里尽可能的保持更大的动态范围，
而且让它能更符合人眼的习惯就成了图形学研究的一个热点。通常真正的HDR的做法都是采用浮点纹理，把渲染运算的过程中，我们使用16bit的
动态范围来保存运算结果，然后我们对运算结果进行分析，求出这个图像的中间灰度值，然后对图像进行调整映射到LDR的设备中。但是这样的算法
有两个非常耗资源的过程，其中一个是浮点纹理，另外一个就是求图像中间灰度（通常情况是把图像不停的渲染到RenderTarget，每渲染一次，
图像大小缩小一半，直到缩小到1x1大，一个1024 x1024的图像需要渲染10次！）。因此虽然HDR的效果非常漂亮，但是目前还是只有为数不多的
游戏采用了这样的算法，大部分都是采用的伪HDR+blow效果。

伪HDR效果通常是重新调整图像的亮度曲线，让亮的更亮，暗的更暗一些，而Blow效果则是图像的亮度扩散开来，产生很柔的效果。

在这里我们采用一个二次曲线来重新调整图像的亮度，这个曲线的方程是
x [ (2-4k) x + 4k-1 ).
K的取值范围为0.5 – 2.0

经过这个公式调整以后，图像上亮的区域将更加的亮，并且整体亮度会提高。那么接下来，我们如何使图像的亮度扩散开来呢？一种可行的方法就是对
场景图像做一次downsample。把它变成原来的1/4次大小，那样就等于亮度往外扩散了4x4个象素的区域。

*/
precision mediump float;
#define GLSLIFY 1
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;

vec4 xposure(vec4 _color, float gray, float ex) {
  float b = (4.0*ex - 1.0);
  float a = 1.0 - b;
  float f = gray*(a*gray + b);
  return f*_color;
}

void main() {
  vec4 _dsColor = texture2D(s_baseMap, v_texCoord);
  float _lum = 0.3*_dsColor.x + 0.59*_dsColor.y;
  vec4 _fColor = texture2D(s_baseMap, v_texCoord);
  float k = 1.6; // k = 1.1
  gl_FragColor = xposure(_fColor, _lum, k);
}
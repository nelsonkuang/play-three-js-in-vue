/*
图像的模糊又成为图像的平滑(smoothing)，我们知道人眼对高频成分是非常敏感的，如果在一个亮度连续变化的图像中，突然出现一个亮点，
那么我们很容易察觉出来，类似的，如果图像有个突然的跳跃—明显的边缘，我们也是很容易察觉出来的。这些突然变化的分量就是图像的高频成分。
人眼通常是通过低频成分来辨别轮廓，通过高频成分来感知细节的（这也是为什么照片分辨率低的时候，人们只能辨认出照片的大概轮廓，而看不到细节）。
但是这些高频成分通常也包含了噪声成分。图像的平滑处理就是滤除图像的高频成分。
通常情况下，我们滤波器的阶数为3已经足够了，用于模糊处理的 3x3滤波器
1/9 *  [1, 1, 1]  
       [1, 1, 1]
       [1, 1, 1]
经过这样的滤波器，其实就是等效于把一个像素和周围8个像素一起求平均值，这是非常合理的---等于把一个像素和周围几个像素搅拌在一起—自然就模糊了。
*/
precision mediump float;
#define GLSLIFY 1
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;

vec4 dip_filter(mat3 _filter, sampler2D _image, vec2 _xy, vec2 texSize) {
  mat3 _filter_pos_delta_x=mat3(vec3(-1.0, 0.0, 1.0), vec3(0.0, 0.0 ,1.0) ,vec3(1.0,0.0,1.0));
  mat3 _filter_pos_delta_y=mat3(vec3(-1.0,-1.0,-1.0),vec3(-1.0,0.0,0.0),vec3(-1.0,1.0,1.0));
  vec4 final_color = vec4(0.0, 0.0, 0.0, 0.0);
  for(int i = 0; i<3; i++) {
    for(int j = 0; j<3; j++) {
      vec2 _xy_new = vec2(_xy.x + _filter_pos_delta_x[i][j], _xy.y + _filter_pos_delta_y[i][j]);
      vec2 _uv_new = vec2(_xy_new.x/texSize.x, _xy_new.y/texSize.y);
      final_color += texture2D(_image,_uv_new) * _filter[i][j];
    }
  }
  return final_color;
}

void main() {
  vec2 intXY = vec2(v_texCoord.x * TexSize.x, v_texCoord.y * TexSize.y);
  // 铅笔描边效果
  // 如果在图像的边缘处，灰度值肯定经过一个跳跃，我们可以计算出这个跳跃，并对这个值进行一些处理，来得到边缘浓黑的描边效果。
  // 首先我们可以考虑对这个象素的左右两个象素进行差值，得到一个差量，这个差量越大，表示图像越处于边缘，而且这个边缘应该左
  // 右方向的，同样我们能得到上下方向和两个对角线上的图像边缘。这样我们构造一个滤波器
  // 经过这个滤波器后，我们得到的是图像在这个象素处的变化差值，我们把它转化成灰度值，并求绝对值（差值可能为负），
  // 然后我们定义差值的绝对值越大的地方越黑（边缘显然是黑的），否则越白，我们便得到如下的效果：
  // 以上是简单的边缘检测算子，更加严格的，我们可以采样Sobel算子（还有其他4种）
  mat3 _smooth_fil = mat3(-0.5, -1.0, 0.0,
  						            -1.0, 0.0, 1.0,
                          0.0, 1.0, 0.5);
  vec4 delColor = dip_filter(_smooth_fil, s_baseMap, intXY, TexSize); 
  vec4 tmp = dip_filter(_smooth_fil, s_baseMap, intXY, TexSize);
  float deltaGray = 0.3*delColor.x + 0.59*delColor.y + 0.11*delColor.z; // 求亮度，即灰度
  if(deltaGray < 0.0) deltaGray = -1.0 * deltaGray;
  deltaGray = 1.0 - deltaGray;
  gl_FragColor = vec4(deltaGray, deltaGray, deltaGray,1.0);
}
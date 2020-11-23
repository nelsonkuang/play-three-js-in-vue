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
  // BOX滤波器
  // mat3 _smooth_fil = mat3(1.0/9.0,1.0/9.0,1.0/9.0,
  // 						            1.0/9.0,1.0/9.0,1.0/9.0,
  //                         1.0/9.0,1.0/9.0,1.0/9.0);
  // 高斯滤波器
  // mat3 _smooth_fil = mat3(1.0/16.0,2.0/16.0,1.0/16.0,
  // 						            2.0/16.0,4.0/16.0,2.0/16.0,
  //                         1.0/16.0,2.0/16.0,1.0/16.0);
  // 拉普拉斯锐化
  mat3 _smooth_fil = mat3(-1.0, -1.0, -1.0,
  						            -1.0,  9.0, -1.0,
                          -1.0, -1.0, -1.0);
  vec4 tmp = dip_filter(_smooth_fil, s_baseMap, intXY, TexSize);
  gl_FragColor = tmp;
}
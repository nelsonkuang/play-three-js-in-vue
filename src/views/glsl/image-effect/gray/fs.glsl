/*
任何颜色都有红、绿、蓝三原色组成，假如原来某点的颜色为RGB(R，G，B)，那么，我们可以通过下面几种方法，将其转换为灰度：
1.浮点算法：Gray=R*0.3+G*0.59+B*0.11
2.整数方法：Gray=(R*30+G*59+B*11)/100
3.移位方法：Gray =(R*76+G*151+B*28)>>8;
4.平均值法：Gray=(R+G+B)/3;
5.仅取绿色：Gray=G；
通过上述任一种方法求得Gray后，将原来的RGB(R,G,B)中的R,G,B统一用Gray替换，形成新的颜色RGB(Gray,Gray,Gray)，用它替换原来的RGB(R,G,B)就是灰度图了。在这里我们使用GPUImage中使用的变换因子：
const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
*/
precision mediump float;
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;

const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

void main() {
  // 灰度图
  lowp vec4 textureColor = texture2D(s_baseMap, v_texCoord);
  float luminance = dot(textureColor.rgb, W);

  gl_FragColor = vec4(vec3(luminance), textureColor.a);
  
  // 图像颠倒
  // vec4 color = texture2D(s_baseMap, vec2(v_texCoord.x, 1.0 - v_texCoord.y));
  // gl_FragColor = color;
}
/*
在开始之前先普及下GPU和CPU的区别：
两者的主要区别在于GPU是完全并行的，具有多个（例如512）逻辑运算单元，但计算能力不如CPU的逻辑运算单元；
CPU虽然有多核的，但一般不多于10 。一般都是 2、4、8核，多于16核的一般人都用不到。
在CPU的编程中你可以假设“邻居”数据而完成一些复杂的算法运算。但在GPU中数据是完全并行的，你不能假设其他数据，这也是
为什么在GPU中你永远看不到“求和”函数的存在，例如在GLSL中，你找不到类似sum的求和函数。


在CPU的多核和多线程、多进程的并行编程中，不是真正严格意义上的并行。因为只要涉及到数据的共享就会导致资源的竞争，
为了数据的一致性和安全，就必须采取加锁（读写锁、自旋锁、RCU等）或者线程等待，这些机制都将会导致某些进程、线程被迫
等待而被内核调度器挂起（或者主动放弃CPU），放在运行等待队列中，等待其他线程的唤起或者再次被内核调度器调度。
好比，茅坑被占了，即使后面有再多的人（线程或者进程）都必须要排队。因此，这就不是真正的并行了。可以说这是真正并行和串行产生的一个折中的处理机制。


GPU的设计是真正的并行设计。因此在编程的过程中你不能假设数据的先后顺序，也不允许访问其他线程的数据。例如sum求和就是一个最明显的例子。
GPU擅长向量的点积和叉积、矩阵变换、插值处理等。
在编写shader的时候，尽量避免使用：
float TWOPI = 3.14*2.0；//应该使用float TWOPI = 6.28；不要让GPU帮你这种已经知道固定值是多少的运算，尤其是浮点运算；
float radius = 10.0/2.0; //应该使用 float radius = 5.0;
float dist = radius / 2.0; //应该使用float dist = radius * 0.5; 尽量避免使用除法；
向量之间相乘，可以使用点积来代替，这是GPU的强项。

遮罩特效
该shader遮罩可以控制：大小、位置、遮罩的颜色、遮罩渐变大小、快慢、明暗程度。
radius：遮罩的半径大小；
gradient：遮罩的渐变速度；
brightness：遮罩的明暗；
color：是否改变被遮罩texture的颜色。
inverted：是否反向，反向的百分比是多少。
*/
precision mediump float;
#define GLSLIFY 1
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
varying vec2 v_texCoord;

const vec4 coefficient = vec4(0.0, 1.0, 0.5, 2.0); /* inverted, radius, gradient, brightness. */
const vec4 color = vec4(1.0, 0.0, 1.0, 1.0);
const vec2 touchPoint = vec2(1024.0, 1024.0);

float getMask(float radius, vec2 pos, vec2 centre){
    float dist = distance(pos, centre);
    if (dist < radius) {
        float dd = dist/radius;
        return smoothstep(0.0, coefficient.z, 1.0 - pow(dd, coefficient.w));
    }
    return 0.0;
}

void main() {
  vec2 uv = -1.0 + 2.0 * v_texCoord; // three.js 里 uv 可以对应 -1.0 + 2.0 * vUv，坐标范围从 [0, 1] 变为 [-1, 1]
  float aspe = TexSize.x / TexSize.y; // 因为要保证非遮罩部分为圆形
  vec2 pos = uv;
  pos.x *= aspe; // 因为要乘以一个比例，所以上面要把坐标范围从 [0, 1] 变为 [-1, 1]
  vec2 centre = (touchPoint.xy / TexSize.xy) * 2.0 - 1.0;
  centre.x *= aspe;
  vec4 tc = texture2D(s_baseMap, vec2(v_texCoord.x, 1.0 - v_texCoord.y)); // 右手坐标系
  float mask = getMask(coefficient.y, pos, centre);
  if (coefficient.x == 0.0)
      gl_FragColor = vec4(tc*mask*color);
  else
      gl_FragColor = vec4(tc*(1.0-coefficient.x*mask*color));
}
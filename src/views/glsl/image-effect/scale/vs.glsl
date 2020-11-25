/*
这里的 duration 表示一次缩放周期的时长，mod(Time, duration) 表示将传入的时间转换到一个周期内，
即 time 的范围是 0 ~ 0.6，amplitude 表示振幅，引入 PI 的目的是为了使用 sin 函数，将 amplitude 的
范围控制在 1.0 ~ 1.3 之间，并随着时间变化。
这里放大的关键在于 vec4(Position.x * amplitude, Position.y * amplitude, Position.zw) ，我们将
顶点坐标的 x 和 y 分别乘上一个放大系数，在纹理坐标不变的情况下，就达到了拉伸的效果。
*/
precision highp float;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform float time;
attribute vec3 position;
attribute vec2 uv;

#define GLSLIFY 1
varying vec2 v_texCoord;

const float PI = 3.1415926;

void main() {
    float duration = 0.6; // 一次缩放周期的时长
    float maxAmplitude = 0.3; // 最大振幅
    float t = mod(time, duration); // 周期内，当前时间
    float amplitude = 1.0 + maxAmplitude * abs(sin(t * (PI / duration))); // 振幅
    vec4 mvpPosition = projectionMatrix * modelViewMatrix * vec4( position, 1.0 ); // 当前位置
    gl_Position = vec4(mvpPosition.x * amplitude, mvpPosition.y * amplitude, mvpPosition.zw); // 乘上一个放大系数
    v_texCoord = uv;
}
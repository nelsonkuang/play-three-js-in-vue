precision highp float;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
attribute vec3 position;
attribute vec2 uv;

#define GLSLIFY 1
varying vec2 v_texCoord;
varying float fogFactor;

void main() {
    v_texCoord = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
    const float LOG2 = 1.442695;
    float fogDensity = 0.041; // 这个参数代表了雾的浓度，越大雾越浓
    float fogDepth = abs(gl_Position.z); // 这样获得距离效率较高
    fogFactor = exp2( -fogDensity * fogDensity * fogDepth * fogDepth * LOG2 ); // 计算雾的权重
    fogFactor = clamp(fogFactor, 0.0, 1.0); // 越界处理
}
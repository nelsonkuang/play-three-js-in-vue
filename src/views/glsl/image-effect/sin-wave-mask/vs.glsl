precision highp float;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
attribute vec3 position;
attribute vec2 uv;

#define GLSLIFY 1
varying vec2 v_texCoord;

void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 ); // 当前位置
    v_texCoord = uv;
}
precision highp float;
precision highp int;
#define HIGH_PRECISION
uniform mat4 modelMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 cameraPosition;
attribute vec3 position;
attribute vec3 normal;
attribute vec2 uv;

#define GLSLIFY 1
varying vec2 vUv;
varying vec3 Normal;
varying vec3 worldNormal;
varying vec3 worldPosition;

void main() {
    vUv = uv;
    worldNormal = (modelMatrix * vec4(normal,0.0)).xyz;
    worldPosition = (modelMatrix * vec4(position, 1.0 )).xyz;
    gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}
/*
ScanLine 就是扫描线。在老机器里面，扫描线经常是清晰可见的。现在由于科技呀，他进步了，扫描线就没了。
但是假如还是为了这个美感的话，我们很容易用现代的，数学的方法把以前的 缺陷 给渲染出来。
*/
precision mediump float;
uniform sampler2D s_baseMap;
uniform vec2 TexSize;
uniform float time;
varying vec2 v_texCoord;

void main() {
  vec2 intXY = vec2(v_texCoord.x * TexSize.x, v_texCoord.y * TexSize.y); // 真实点坐标
  vec4 curColor = texture2D(s_baseMap, v_texCoord); // 当前颜色
  const float speed = 20.0;
  // curColor.rgb -= (mod(v_texCoord.y, 2.0) <= 1.0 ? 0.1 : 0.0);
  curColor.rgb -= (mod(intXY.y + ceil(time * speed), 2.0) <= 1.0 ? 0.1 : 0.0);
  gl_FragColor = vec4(curColor.rgb, 1.0);
}
const THREE = require('three')
// Referenced from: https://github.com/ykob/js-util/blob/master/MathEx.js
export function degrees (radian) {
  return radian / Math.PI * 180;
}
export function radians (degree) {
  return degree * Math.PI / 180;
}
export function clamp (value, min, max) {
  return Math.min(Math.max(value, min), max);
}
export function mix (x1, x2, a) {
  return x1 * (1 - a) + x2 * a;
}
export function step (e, x) {
  return (x >= e) ? 1 : 0;
}
export function smoothstep (e0, e1, x) {
  if (e0 >= e1) return undefined;
  var t = Math.min(Math.max((x - e0) / (e1 - e0), 0), 1);
  return t * t * (3 - 2 * t);
}
export function spherical (radian1, radian2, radius) {
  return [
    Math.cos(radian1) * Math.cos(radian2) * radius,
    Math.sin(radian1) * radius,
    Math.cos(radian1) * Math.sin(radian2) * radius,
  ];
}
export function randomArbitrary (min, max) {
  return Math.random() * (max - min) + min;
}
export function randomInt (min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

export function computeFaceNormal (p0, p1, p2) {
  const n = [];
  const v1 = [p1[0] - p0[0], p1[1] - p0[1], p1[2] - p0[2]];
  const v2 = [p2[0] - p0[0], p2[1] - p0[1], p2[2] - p0[2]];
  n[0] = v1[1] * v2[2] - v1[2] * v2[1];
  n[1] = v1[2] * v2[0] - v1[0] * v2[2];
  n[2] = v1[0] * v2[1] - v1[1] * v2[0];
  const l = Math.sqrt(n[0] * n[0] + n[1] * n[1] + n[2] * n[2], 2);
  for (var i = 0; i < n.length; i++) {
    n[i] = n[i] / l;
  }
  return n;
}

export function getPolarCoord (rad1, rad2, r) {
  const x = Math.cos(rad1) * Math.cos(rad2) * r
  const z = Math.cos(rad1) * Math.sin(rad2) * r
  const y = Math.sin(rad1) * r
  return new THREE.Vector3(x, y, z)
}

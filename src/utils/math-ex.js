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

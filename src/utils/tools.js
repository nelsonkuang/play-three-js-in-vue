export function debounce (callback, duration) {
  let timer
  return function () {
    clearTimeout(timer)
    const args = [...arguments]
    timer = setTimeout(function () {
      callback(...args)
    }, duration)
  }
}

export function normalizeVector2 (vector, width, height) {
  vector.x = (vector.x / width) * 2 - 1
  vector.y = - (vector.y / height) * 2 + 1
}

// Add your prefix here.
const browserPrefixes = [
  '',
  'MOZ_',
  'OP_',
  'WEBKIT_',
];
/**
 * Given an extension name like WEBGL_compressed_texture_s3tc
 * returns the supported version extension, like
 * WEBKIT_WEBGL_compressed_teture_s3tc
 * @param {string} name Name of extension to look for
 * @return {WebGLExtension} The extension or undefined if not
 *     found.
 * @memberOf module:webgl-utils
 */
export function getExtensionWithKnownPrefixes (gl, name) {
  for (let ii = 0; ii < browserPrefixes.length; ++ii) {
    const prefixedName = browserPrefixes[ii] + name;
    const ext = gl.getExtension(prefixedName);
    if (ext) {
      return ext;
    }
  }
  return undefined;
}
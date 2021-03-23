import * as THREE from 'three'

import vs from './shaders/post-effect.vs.glsl'
import fs from './shaders/post-effect-bright.fs.glsl'

export default class PostEffectBright extends THREE.Mesh {
  nelType = 'PostEffectBright'
  constructor() {
    // Define Geometry
    const geometry = new THREE.PlaneBufferGeometry(2, 2)

    // Define Material
    const material = new THREE.RawShaderMaterial({
      uniforms: {
        minBright: {
          value: 0.5
        },
        texture: {
          value: null
        },
      },
      vertexShader: vs,
      fragmentShader: fs,
    })

    // Create Object3D
    super(geometry, material)
  }
  start (texture) {
    this.material.uniforms.texture.value = texture
  }
}

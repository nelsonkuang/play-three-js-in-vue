import * as THREE from 'three'

import vs from './shaders/post-effect.vs.glsl'
import fs from './shaders/post-effect-bloom.fs.glsl'

export default class PostEffectBloom extends THREE.Mesh {
  nelType = 'PostEffectBloom'
  constructor() {
    // Define Geometry
    const geometry = new THREE.PlaneBufferGeometry(2, 2)

    // Define Material
    const material = new THREE.RawShaderMaterial({
      uniforms: {
        texture1: {
          value: null
        },
        texture2: {
          value: null
        },
      },
      vertexShader: vs,
      fragmentShader: fs,
    })

    // Create Object3D
    super(geometry, material)
  }
  start(texture1, texture2) {
    this.material.uniforms.texture1.value = texture1
    this.material.uniforms.texture2.value = texture2
  }
}

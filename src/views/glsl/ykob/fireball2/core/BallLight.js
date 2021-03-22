import * as THREE from 'three'

import vs from './shaders/ball-light.vs.glsl'
import fs from './shaders/ball-light.fs.glsl'

export default class BallLight extends THREE.Mesh {
  nelType = 'BallLight'
  constructor() {
    // Define Geometry
    const geometry = new THREE.PlaneBufferGeometry(30, 30)

    // Define Material
    const material = new THREE.RawShaderMaterial({
      uniforms: {
        time: {
          value: 0
        },
        noiseTex: {
          value: null
        },
        acceleration: {
          value: new THREE.Vector3()
        }
      },
      vertexShader: vs,
      fragmentShader: fs,
      transparent: true,
      blending: THREE.AdditiveBlending
    })

    // Create Object3D
    super(geometry, material)
  }
  start (noiseTex) {
    const { uniforms } = this.material

    uniforms.noiseTex.value = noiseTex
  }
  update (time, Ball) {
    const { uniforms } = this.material

    uniforms.time.value += time
    uniforms.acceleration.value.copy(Ball.acceleration)
    this.position.copy(Ball.position)
  }
}

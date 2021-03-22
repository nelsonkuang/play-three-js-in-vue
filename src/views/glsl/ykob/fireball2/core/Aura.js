import * as THREE from 'three'

import vs from './shaders/aura.vs.glsl'
import fs from './shaders/aura.fs.glsl'

export default class Aura extends THREE.Mesh {
  nelType = 'Aura'
  constructor() {
    // Define Geometry
    const geometry = new THREE.OctahedronBufferGeometry(10.1, 10)

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
      side: THREE.DoubleSide
    })

    // Create Object3D
    super(geometry, material)
  }
  start(noiseTex) {
    const { uniforms } = this.material

    uniforms.noiseTex.value = noiseTex
  }
  update(time, core) {
    const { uniforms } = this.material

    uniforms.time.value += time
    uniforms.acceleration.value.copy(core.acceleration)
    this.position.copy(core.position)
  }
}

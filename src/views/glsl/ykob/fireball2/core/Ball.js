import * as THREE from 'three'

import vs from './shaders/ball.vs.glsl'
import fs from './shaders/ball.fs.glsl'

export default class Ball extends THREE.Mesh {
  nelType = 'Ball'
  constructor() {
    // Define Geometry
    const geometry = new THREE.OctahedronBufferGeometry(10, 6)

    // Define Material
    const material = new THREE.RawShaderMaterial({
      uniforms: {
        time: {
          value: 0
        },
        noiseTex: {
          value: null
        }
      },
      vertexShader: vs,
      fragmentShader: fs
    })

    // Create Object3D
    super(geometry, material)
    this.acceleration = new THREE.Vector3()
    this.anchor = new THREE.Vector3()
  }
  start (noiseTex) {
    const { uniforms } = this.material

    uniforms.noiseTex.value = noiseTex
  }
  update (time, camera) {
    const { uniforms } = this.material

    uniforms.time.value += time
    this.applyHook(0, 0.2)
    this.applyDrag(0.6)
    this.position.add(this.acceleration)
    this.lookAt(camera.position)
  }
  applyDrag (value) {
    const force = this.acceleration.clone()

    force.multiplyScalar(-1)
    force.normalize()
    force.multiplyScalar(this.acceleration.length() * value)
    this.acceleration.add(force)
  }
  applyHook (restLength, k) {
    const force = this.position.clone().sub(this.anchor)
    const distance = force.length() - restLength

    force.normalize()
    force.multiplyScalar(-1 * k * distance)
    this.acceleration.add(force)
  }
}

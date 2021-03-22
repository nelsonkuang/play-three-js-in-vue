import * as THREE from 'three'
import { radians } from '@/utils/math-ex'

import vs from './shaders/background.vs.glsl'
import fs from './shaders/background.fs.glsl'

export default class Background extends THREE.Mesh {
  nelType = 'Background'
  constructor() {
    // Define Geometry
    const geometry = new THREE.PlaneBufferGeometry(1, 1)

    // Define Material
    const material = new THREE.RawShaderMaterial({
      uniforms: {
        time: {
          value: 0
        },
        resolution: {
          value: new THREE.Vector2()
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
    this.position.z = -1000
  }
  start(texture) {
    const { uniforms } = this.material

    uniforms.noiseTex.value = texture
  }
  update(time) {
    const { uniforms } = this.material

    uniforms.time.value += time
  }
  resize(camera, resolution) {
    const { uniforms } = this.material
    const height = Math.abs(
      (camera.position.z - this.position.z) *
        Math.tan(radians(camera.fov) / 2) *
        2
    )
    const width = height * camera.aspect

    this.scale.set(width, height, 1)
    uniforms.resolution.value.copy(resolution)
  }
}

import Force3 from './Force3'

const THREE = require('three')

class Points extends Force3 {
  nelType = 'Points'
  
  constructor() {
    super()
    this.geometry = new THREE.BufferGeometry()
    this.material = null
    this.obj
  }

  init (options) {
    this.material = new THREE.ShaderMaterial({
      uniforms: {
        color: { type: 'c', value: new THREE.Color(0xffffff) },
        texture: { type: 't', value: options.texture }
      },
      vertexShader: options.vs,
      fragmentShader: options.fs,
      transparent: true,
      depthWrite: false,
      blending: options.blending
    })
    this.geometry.setAttribute('position', new THREE.BufferAttribute(options.positions, 3))
    this.geometry.setAttribute('customColor', new THREE.BufferAttribute(options.colors, 3))
    this.geometry.setAttribute('vertexOpacity', new THREE.BufferAttribute(options.opacities, 1))
    this.geometry.setAttribute('size', new THREE.BufferAttribute(options.sizes, 1))
    this.obj = new THREE.Points(this.geometry, this.material)
    options.scene.add(this.obj)
  }

  updatePoints () {
    this.obj.position.copy(this.velocity)
    this.obj.geometry.attributes.position.needsUpdate = true
    this.obj.geometry.attributes.vertexOpacity.needsUpdate = true
    this.obj.geometry.attributes.size.needsUpdate = true
    this.obj.geometry.attributes.customColor.needsUpdate = true
  }
}

export default Points
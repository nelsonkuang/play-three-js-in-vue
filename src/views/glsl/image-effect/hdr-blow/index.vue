<template>
  <div id="canvas" ref="canvas" class="canvas"></div>
</template>

<script>
// 参考引用：https://blog.csdn.net/neng18/article/details/38083987
/* eslint-disable no-alert, no-console */
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import vertexShader from './vs.glsl'
import fragmentShader from './fs.glsl'
let timer = null
export default {
  data () {
    return {
    }
  },
  computed: {
  },
  mounted () {
    let container = this.$refs.canvas
    let camera, scene, renderer
    let plane
    function init () {
      camera = new THREE.PerspectiveCamera(40, container.clientWidth / container.clientHeight, 1, 1000)
      camera.position.set(0.0, 0.0, 10 * 3);
      scene = new THREE.Scene()
      const tWidth = 20.0
      const tHeight = 20.0
      // const imgWidth = 2048.0
      // const imgHeight = 2048.0
      const geometry = new THREE.PlaneGeometry(tWidth, tHeight, 1)
      const material = new THREE.RawShaderMaterial({
        vertexShader: vertexShader,
        fragmentShader: fragmentShader,
        side: THREE.DoubleSide,
        uniforms: {
          's_baseMap': { type: 't', value: new THREE.TextureLoader().load('./static/img/cube/Park2/py.jpg') },
          'TexSize': { value: [container.clientWidth / container.clientHeight] },
          'modelViewMatrix': { value: null },
          'projectionMatrix': { value: null },
        },
      })
      plane = new THREE.Mesh(geometry, material)
      scene.add(plane)

      plane.material.uniforms['modelViewMatrix'].value = plane.modelViewMatrix
      plane.material.uniforms['projectionMatrix'].value = camera.projectionMatrix

      renderer = new THREE.WebGLRenderer({ antialias: true })
      // renderer.debug.checkShaderErrors = false
      renderer.setPixelRatio(window.devicePixelRatio)
      renderer.setSize(container.clientWidth, container.clientHeight)
      // renderer.shadowMap.enabled = true
      container.appendChild(renderer.domElement)

      const controls = new OrbitControls(camera, renderer.domElement)
      controls.minDistance = 0.01
      controls.maxDistance = 100
      controls.target.set(0, 0, 0)
      controls.update()

      window.addEventListener('resize', onWindowResize, false)
    }
    function onWindowResize () {
      const width = container.clientWidth
      const height = container.clientHeight
      camera.aspect = width / height
      camera.updateProjectionMatrix()
      renderer.setSize(width, height)
    }
    function animate () {
      timer = requestAnimationFrame(animate)
      render()
    }
    function render () {
      renderer.render(scene, camera)
    }
    init()
    animate()
  },
  beforeDestroy () {
    timer && cancelAnimationFrame(timer)
    timer = null
  }
}
</script>
<style scoped>
.canvas {
  width: 100%;
  height: 100%;
  min-height: 99.99vh;
  position: relative;
}
</style>
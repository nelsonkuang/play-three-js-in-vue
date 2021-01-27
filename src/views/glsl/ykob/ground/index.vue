<template>
  <div id="canvas" ref="canvas" class="canvas"></div>
</template>

<script>
// 参考引用：https://ykob.github.io/sketch-threejs/
/* eslint-disable no-alert, no-console */
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import vertexShader from './vs.glsl'
import fragmentShader from './fs.glsl'
import { radians } from '@/utils/math-ex'
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
      camera = new THREE.PerspectiveCamera(45, container.clientWidth / container.clientHeight, 1, 1000)
      camera.position.set(0.0, 0.0, 10 * 3);
      scene = new THREE.Scene()
      const tWidth = 1024.0
      const tHeight = 1024.0
      // const imgWidth = 900.0
      // const imgHeight = 900.0
      const geometry = new THREE.PlaneBufferGeometry(tWidth, tHeight, 32, 32)
      const material = new THREE.RawShaderMaterial({
        vertexShader: vertexShader,
        fragmentShader: fragmentShader,
        transparent: true,
        wireframe: true,
        // side: THREE.DoubleSide,
        uniforms: {
          time: {
            type: 'f',
            value: 0
          }
        },
      })
      plane = new THREE.Mesh(geometry, material)
      plane.position.set(0, -60, 0)
      plane.rotation.set(radians(-90), 0, 0)
      scene.add(plane)

      renderer = new THREE.WebGLRenderer({ antialias: true })
      // renderer.debug.checkShaderErrors = false
      renderer.setPixelRatio(window.devicePixelRatio)
      renderer.setSize(container.clientWidth, container.clientHeight)
      // renderer.shadowMap.enabled = true
      container.appendChild(renderer.domElement)

      const controls = new OrbitControls(camera, renderer.domElement)
      controls.minDistance = 0.01
      controls.maxDistance = 1000
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
    function animate (time) {
      timer = requestAnimationFrame(animate)
      plane.material.uniforms['time'].value = time * 0.001
      render()
    }
    function render () {
      renderer.render(scene, camera)
    }
    init()
    animate(0)
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
<template>
  <div id="canvas" ref="canvas" class="canvas"></div>
</template>

<script>
// 参考引用：https://threejs.org/examples/#webgl_materials_physical_reflectivity
/* eslint-disable no-alert, no-console */
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import Stats from 'three/examples/jsm/libs/stats.module'
import { GUI } from 'three/examples/jsm/libs/dat.gui.module'
import { OBJLoader } from 'three/examples/jsm/loaders/OBJLoader'
import { RGBELoader } from 'three/examples/jsm/loaders/RGBELoader'
let gui = null
let timer = null
export default {
  data () {
    return {
    }
  },
  computed: {
  },
  mounted () {
    let container = this.$refs.canvas, stats
    const params = {
      projection: 'normal',
      autoRotate: true,
      reflectivity: 1.0,
      background: false,
      exposure: 1.0,
      gemColor: 'Green'
    }
    let camera, scene, renderer
    let gemBackMaterial, gemFrontMaterial
    let hdrCubeRenderTarget

    const objects = []

    init()
    animate()
    function init () {
      camera = new THREE.PerspectiveCamera(40, container.clientWidth / container.clientHeight, 1, 1000)
      camera.position.set(0.0, - 10, 20 * 3.5);
      scene = new THREE.Scene()
      scene.background = new THREE.Color(0x000000);
      renderer = new THREE.WebGLRenderer({ antialias: true })

      gemBackMaterial = new THREE.MeshPhysicalMaterial({
        map: null,
        color: 0x0000ff,
        metalness: 1,
        roughness: 0,
        opacity: 0.5,
        side: THREE.BackSide,
        transparent: true,
        envMapIntensity: 5,
        premultipliedAlpha: true
        // TODO: Add custom blend mode that modulates background color by this materials color.
      })

      gemFrontMaterial = new THREE.MeshPhysicalMaterial({
        map: null,
        color: 0x0000ff,
        metalness: 0,
        roughness: 0,
        opacity: 0.25,
        side: THREE.FrontSide,
        transparent: true,
        envMapIntensity: 10,
        premultipliedAlpha: true
      })

      const manager = new THREE.LoadingManager()
      manager.onProgress = function (item, loaded, total) {
        console.log(item, loaded, total);
      }

      const loader = new OBJLoader(manager)
      loader.load('./static/models/obj/emerald.obj', function (object) {
        object.traverse(function (child) {
          if (child instanceof THREE.Mesh) {
            child.material = gemBackMaterial
            const second = child.clone()
            second.material = gemFrontMaterial
            const parent = new THREE.Group()
            parent.add(second)
            parent.add(child)
            scene.add(parent)
            objects.push(parent)
          }
        })
      })

      new RGBELoader()
        .setDataType(THREE.UnsignedByteType)
        .setPath('./static/textures/equirectangular/')
        .load('royal_esplanade_1k.hdr', function (hdrEquirect) {
          hdrCubeRenderTarget = pmremGenerator.fromEquirectangular(hdrEquirect) // 全景贴图 royal_esplanade_1k
          pmremGenerator.dispose()
          gemFrontMaterial.envMap = gemBackMaterial.envMap = hdrCubeRenderTarget.texture // 表面使用全景贴图
          gemFrontMaterial.needsUpdate = gemBackMaterial.needsUpdate = true
          hdrEquirect.dispose()
        })

      const pmremGenerator = new THREE.PMREMGenerator(renderer)
      pmremGenerator.compileEquirectangularShader()

      // Lights
      scene.add(new THREE.AmbientLight(0x222222)) // 环境光

      const pointLight1 = new THREE.PointLight(0xffffff) // 点光源
      pointLight1.position.set(150, 10, 0)
      pointLight1.castShadow = false
      scene.add(pointLight1)

      const pointLight2 = new THREE.PointLight(0xffffff)
      pointLight2.position.set(-150, 0, 0)
      scene.add(pointLight2)

      const pointLight3 = new THREE.PointLight(0xffffff)
      pointLight3.position.set(0, -10, -150)
      scene.add(pointLight3)

      const pointLight4 = new THREE.PointLight(0xffffff)
      pointLight4.position.set(0, 0, 150)
      scene.add(pointLight4)

      renderer.setPixelRatio(window.devicePixelRatio)
      renderer.setSize(container.clientWidth, container.clientHeight)
      renderer.shadowMap.enabled = true
      container.appendChild(renderer.domElement)

      renderer.outputEncoding = THREE.sRGBEncoding

      stats = new Stats()
      container.appendChild(stats.dom)

      const controls = new OrbitControls(camera, renderer.domElement)
      controls.minDistance = 20
      controls.maxDistance = 200

      window.addEventListener('resize', onWindowResize, false)

      GUI.TEXT_CLOSED = '关闭控制面板'
      GUI.TEXT_OPEN = '打开控制面板'
      gui = new GUI()
      gui.add(params, 'reflectivity', 0, 1).name('反射率')
      gui.add(params, 'exposure', 0.1, 2).name('曝光率')
      gui.add(params, 'autoRotate').name('自动旋转')
      gui.add(params, 'gemColor', {
        '蓝色': 'Blue',
        '绿色': 'Green',
        '红色': 'Red',
        '白色': 'White',
        '黑色': 'Black'
      }).name('宝石颜色')
      gui.open()
    }

    function onWindowResize () {
      const width = container.clientWidth
      const height = container.clientHeight
      camera.aspect = width / height
      camera.updateProjectionMatrix()
      renderer.setSize(width, height)
    }
    //
    function animate () {
      timer = requestAnimationFrame(animate)
      stats.begin()
      render()
      stats.end()
    }

    function render () {
      if (gemBackMaterial !== undefined && gemFrontMaterial !== undefined) {
        gemFrontMaterial.reflectivity = gemBackMaterial.reflectivity = params.reflectivity
        let newColor = gemBackMaterial.color
        switch (params.gemColor) {
          case 'Blue': newColor = new THREE.Color(0x000088)
            break
          case 'Red': newColor = new THREE.Color(0x880000)
            break
          case 'Green': newColor = new THREE.Color(0x008800)
            break
          case 'White': newColor = new THREE.Color(0x888888)
            break
          case 'Black': newColor = new THREE.Color(0x0f0f0f)
            break
        }
        gemBackMaterial.color = gemFrontMaterial.color = newColor
      }
      renderer.toneMappingExposure = params.exposure
      camera.lookAt(scene.position)
      if (params.autoRotate) {
        for (let i = 0, l = objects.length; i < l; i++) {
          const object = objects[i]
          object.rotation.y += 0.005
        }
      }
      renderer.render(scene, camera)

    }
  },
  beforeDestroy () {
    timer && cancelAnimationFrame(timer)
    gui && gui.destroy()
    gui = null
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
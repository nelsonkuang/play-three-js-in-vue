<template>
  <div id="canvas" ref="canvas" class="canvas"></div>
</template>

<script>
// 参考引用：https://github.com/wenluzhizhi/threejs_Diamond_shader
// https://ydz.gemcool.cn/custom/exclusive?storeId=MTAwMDE%3D&modelId=5e85626a42268956a44a6b76&diamondColorIndex=undefined&MainDiamondColorIndex=9&DSMDiamondColorIndex=9&ringColorIndex=3&femaleRingRingColor=3&femaleMainDiamondColorIndex=9&femaleDSMDiamondColorIndex=9&maleRingRingColor=3&maleMainDiamondColorIndex=9&maleDSMDiamondColorIndex=9%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20&type=10003&isCollect=true&storeProductId=216208
/* eslint-disable no-alert, no-console */
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
// import Stats from 'three/examples/jsm/libs/stats.module'
// import { GUI } from 'three/examples/jsm/libs/dat.gui.module'
// import { HDRCubeTextureLoader } from 'three/examples/jsm/loaders/HDRCubeTextureLoader'
// import { RGBELoader } from 'three/examples/jsm/loaders/RGBELoader'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader'
import { getDpMaterial } from './shader-material'
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
    let container = this.$refs.canvas
    let camera, scene, renderer, gltf
    // let hdrCubeRenderTarget, hdrCubeMap
    let cubeMap, envMap, cubeTexture
    let object, meshes = []
    init()
    function init () {
      camera = new THREE.PerspectiveCamera(40, container.clientWidth / container.clientHeight, 1, 1000)
      camera.position.set(0.0, 5, 5 * 3.5)
      scene = new THREE.Scene()

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

      cubeTexture = new THREE.CubeTextureLoader().setPath('./static/img/cube/Park2/')
        .load(
          [
            'px.jpg',
            'nx.jpg',
            'py.jpg',
            'ny.jpg',
            'pz.jpg',
            'nz.jpg'
          ]
        )
      cubeTexture.mapping = THREE.CubeReflectionMapping

      envMap = new THREE.TextureLoader().load('./static/img/specular-tex.jpg')
      envMap.mapping = THREE.EquirectangularReflectionMapping
      envMap.encoding = THREE.sRGBEncoding

      cubeMap = new THREE.CubeTextureLoader().setPath('./static/img/')
        .load(
          [
            'dpEnvMap.png',
            'dpEnvMap.png',
            'dpEnvMap.png',
            'dpEnvMap.png',
            'dpEnvMap.png',
            'dpEnvMap.png'
          ]
        )
      cubeMap.mapping = THREE.CubeReflectionMapping
      cubeMap.encoding = THREE.sRGBEncoding

      const gltfLoader = new GLTFLoader()
      gltfLoader.load('./static/models/glb/diamond.glb', function (data) {
        gltf = data
        object = gltf.scene
        object.traverse(function (node) {
          if (node.material && (node.material.isMeshStandardMaterial ||
            (node.material.isShaderMaterial && node.material.envMap !== undefined))) {
            node.material = getDpMaterial(THREE, cubeMap, envMap, THREE.DoubleSide)
            node.material.needsUpdate = true
            // const second = node.clone()
            // second.material = getDpMaterial(THREE, cubeMap, envMap, THREE.BackSide)
            // second.material.needsUpdate = true
            // object.add(second)
            meshes = [node]
          }
        })
        scene.add(object)
        scene.background = cubeTexture
        animate()
      }, undefined, function (error) {
        console.error(error)
      })

      // Lights
      scene.add(new THREE.AmbientLight(0xffffff)) // 环境光
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
      object.rotation.y += 0.005
      // let mat = new THREE.Matrix4().getInverse(object.matrix)
      meshes.forEach((mesh) => {
        mesh.material.uniforms['modelMatrix'].value = object.matrix
        mesh.material.uniforms['inverseModelMatrix'].value = new THREE.Matrix4().getInverse(object.matrix)
        mesh.material.uniforms['modelViewMatrix'].value = object.modelViewMatrix
        mesh.material.uniforms['projectionMatrix'].value = camera.projectionMatrix
        mesh.material.uniforms['cameraPosition'].value = camera.position
        mesh.material.uniforms['iResolution'].value = [container.clientWidth, container.clientHeight]
      })
      // renderer.toneMappingExposure = 5.0
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
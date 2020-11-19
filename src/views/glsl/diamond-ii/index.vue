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
import { HDRCubeTextureLoader } from 'three/examples/jsm/loaders/HDRCubeTextureLoader'
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
    let hdrCubeMap, hdrCubeRenderTarget
    let cubeMap, envMap
    let object, meshes = []
    init()
    function init () {
      camera = new THREE.PerspectiveCamera(40, container.clientWidth / container.clientHeight, 1, 1000)
      camera.position.set(0.0, - 10, 20 * 3.5);
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

      const pmremGenerator = new THREE.PMREMGenerator(renderer)
      pmremGenerator.compileCubemapShader()

      envMap = new THREE.CubeTextureLoader().setPath('./static/img/')
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
      envMap.mapping = THREE.CubeRefractionMapping
      hdrCubeMap = new HDRCubeTextureLoader()
        .setPath('./static/textures/equirectangular/')
        .setDataType(THREE.UnsignedByteType)
        .load([
          'px.hdr', 'nx.hdr', 'py.hdr', 'ny.hdr', 'pz.hdr', 'nz.hdr'
        ], function () {
          hdrCubeRenderTarget = pmremGenerator.fromCubemap(hdrCubeMap)
          hdrCubeMap.magFilter = THREE.LinearFilter
          hdrCubeMap.needsUpdate = true

          cubeMap = hdrCubeRenderTarget
          cubeMap.mapping = THREE.CubeRefractionMapping
          const gltfLoader = new GLTFLoader()
          gltfLoader.load('./static/models/glb/diamond.glb', function (data) {
            gltf = data
            object = gltf.scene
            object.traverse(function (node) {
              if (node.material && (node.material.isMeshStandardMaterial ||
                (node.material.isShaderMaterial && node.material.envMap !== undefined))) {
                node.material = getDpMaterial(THREE, envMap, cubeMap, THREE.FrontSide)
                const second = node.clone()
                second.material = getDpMaterial(THREE, envMap, cubeMap, THREE.BackSide)
                object.add(second)
                meshes = [node, second]
              }
            })
            scene.add(object)
            scene.background = envMap
            animate()
          }, undefined, function (error) {
            console.error(error)
          })
        })

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
      let mat = new THREE.Matrix4()
      mat.getInverse(object.matrix)
      object.rotation.y += 0.005
      meshes.forEach((mesh) => {
        mesh.material.uniforms['modelMatrix'].value = object.matrix
        mesh.material.uniforms['InverseModelMatrix'].value = mat
        mesh.material.uniforms['modelViewMatrix'].value = object.modelViewMatrix
        mesh.material.uniforms['projectionMatrix'].value = camera.projectionMatrix
        mesh.material.uniforms['cameraPosition'].value = camera.position
      })
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
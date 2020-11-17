<template>
  <div id="canvas" ref="canvas" class="canvas"></div>
</template>

<script>
// 参考引用：https://github.com/wenluzhizhi/threejs_Diamond_shader
/* eslint-disable no-alert, no-console */
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import Stats from 'three/examples/jsm/libs/stats.module'
import { GUI } from 'three/examples/jsm/libs/dat.gui.module'
import { OBJLoader2 } from 'three/examples/jsm/loaders/OBJLoader2'
import { getFrontMaterial, getBackMaterial } from './shader-material'
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
      autoRotate: true,
      reflectionStrength: 2.0,
      // exposure: 1.1,
      environmentLight: 0.4,
      Color: [1, 1, 1], // RGB array
      emission: 0.19,
      backAlpha: 0.5,
      frontAlpha: 0.5
    }
    let camera, scene, renderer
    let cubeTexture, refractTexture
    let pmremGenerator
    const objects = []
    init()
    animate()
    function init () {
      camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.25, 200)
      camera.position.set(- 1.8, 0.6, 2.7)
      scene = new THREE.Scene()
      renderer = new THREE.WebGLRenderer({ antialias: true })
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
      cubeTexture.mapping = THREE.CubeRefractionMapping
      refractTexture = new THREE.CubeTextureLoader().setPath('./static/img/cube/12/')
        .load(
          [
            '4.jpg',
            '4.jpg',
            '4.jpg',
            '4.jpg',
            '4.jpg',
            '4.jpg'
          ]
        )
      refractTexture.mapping = THREE.CubeRefractionMapping
      const manager = new THREE.LoadingManager()
      manager.onProgress = function (item, loaded, total) {
        console.log(item, loaded, total)
      }
      const loader = new OBJLoader2(manager)
      loader.load('./static/models/obj/diamonds/RoundCut.obj', function (object) {
        const backModel = object.children[0]
        backModel.material = getBackMaterial(THREE, cubeTexture, refractTexture)
        const frontModel = backModel.clone(true)
        frontModel.material = getFrontMaterial(THREE, cubeTexture, refractTexture)
        backModel.add(frontModel)
        objects.push(backModel)
        scene.add(backModel)
        scene.background = cubeTexture
      })
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
      renderer.debug.checkShaderErrors = false
      renderer.setPixelRatio(window.devicePixelRatio)
      renderer.setSize(container.clientWidth, container.clientHeight)
      // renderer.shadowMap.enabled = true
      container.appendChild(renderer.domElement)
      renderer.outputEncoding = THREE.sRGBEncoding
      pmremGenerator = new THREE.PMREMGenerator(renderer)
      pmremGenerator.compileEquirectangularShader()
      stats = new Stats()
      container.appendChild(stats.dom)
      const controls = new OrbitControls(camera, renderer.domElement)
      controls.minDistance = 0.01
      controls.maxDistance = 100
      controls.target.set(0, 0, 0)
      controls.update()
      window.addEventListener('resize', onWindowResize, false)
      GUI.TEXT_CLOSED = '关闭控制面板'
      GUI.TEXT_OPEN = '打开控制面板'
      gui = new GUI()
      gui.addColor(params, 'Color').name('颜色').onChange((value) => {
        setModelUniformsC3("Color", value)
      })
      gui.add(params, 'reflectionStrength', 0, 2).name('反射强度').onChange((value) => {
        setModelUniformsV1("reflectionStrength", value)
      })
    //   gui.add(params, 'exposure', 0.1, 2).name('曝光').onChange( function ( value ) {
    //    renderer.toneMappingExposure = Math.pow( value, 4.0 )
    // } )
      gui.add(params, 'environmentLight', 0, 2).name('环境光').onChange((value) => {
        setModelUniformsV1("environmentLight", value)
      })
      gui.add(params, 'emission', 0, 2).name('发射').onChange((value) => {
        setModelUniformsV1("emission", value)
      })
      gui.add(params, 'backAlpha', 0, 1).name('前面透明度').onChange((value) => {
        setModelUniformsV1("backAlpha", value)
      })
      gui.add(params, 'frontAlpha', 0, 1).name('背面透明度').onChange((value) => {
        setModelUniformsV1("frontAlpha", value)
      })
      gui.add(params, 'autoRotate').name('自动旋转')
      gui.open()
    }
    function onWindowResize () {
      const width = container.clientWidth
      const height = container.clientHeight
      camera.aspect = width / height
      camera.updateProjectionMatrix()
      renderer.setSize(width, height)
    }
    function setModelUniformsV3 (item, param, v3) {
      item.material.uniforms[param].value[0] = v3.x;
      item.material.uniforms[param].value[1] = v3.y;
      item.material.uniforms[param].value[2] = v3.z;
      item.children[0].material.uniforms[param].value[0] = v3.x;
      item.children[0].material.uniforms[param].value[1] = v3.y;
      item.children[0].material.uniforms[param].value[2] = v3.z;
    }

    function setModelUniformsV1 (param, v1) {
      objects.forEach((item) => {
        item.material.uniforms[param].value = v1;
        item.children[0].material.uniforms[param].value = v1;
      });
    }

    function setModelUniformsC3 (param, value) {
      objects.forEach((item) => {
        item.material.uniforms[param].value = new THREE.Vector3(value[0] / 255, value[1] / 255, value[2] / 255);
        item.children[0].material.uniforms[param].value = new THREE.Vector3(value[0] / 255, value[1] / 255, value[2] / 255);
      });
    }
    function animate () {
      timer = requestAnimationFrame(animate)
      stats.begin()
      render()
      stats.end()
    }
    function render () {
      let mat = new THREE.Matrix4();
      let modlePos = new THREE.Vector3();
      modlePos.copy(camera.position);
      objects.forEach((item) => {
        modlePos.applyMatrix4(mat.getInverse(item.matrix));
        setModelUniformsV3(item, "cameraWorldPos", modlePos);
        //item.rotation.x += 0.01;
      })
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
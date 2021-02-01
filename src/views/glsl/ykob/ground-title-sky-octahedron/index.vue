<template>
  <div id="canvas" ref="canvas" class="canvas"></div>
</template>

<script>
// 参考引用：https://ykob.github.io/sketch-threejs/
/* eslint-disable no-alert, no-console */
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import groundVertexShader from './ground-vs.glsl'
import groundFragmentShader from './ground-fs.glsl'
import titleVertexShader from './title-vs.glsl'
import titleFragmentShader from './title-fs.glsl'
import skyOctahedronVertexShader from './skyOctahedron-vs.glsl'
import skyOctahedronFragmentShader from './skyOctahedron-fs.glsl'
import { radians, computeFaceNormal } from '@/utils/math-ex'
// import { getExtensionWithKnownPrefixes } from '@/utils/web-gl'
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
    let ground, title, skyOctahedron
    let now
    function init () {
      camera = new THREE.PerspectiveCamera(45, container.clientWidth / container.clientHeight, 1, 1000)
      camera.position.set(0.0, 0.0, 55 * 3);
      scene = new THREE.Scene()
      const tWidth = 1024.0
      const tHeight = 1024.0
      // const imgWidth = 900.0
      // const imgHeight = 900.0
      const groundGeometry = new THREE.PlaneBufferGeometry(tWidth, tHeight, 32, 32)
      const groundMaterial = new THREE.RawShaderMaterial({
        vertexShader: groundVertexShader,
        fragmentShader: groundFragmentShader,
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
      ground = new THREE.Mesh(groundGeometry, groundMaterial)
      ground.position.set(0, -60, 0)
      ground.rotation.set(radians(-90), 0, 0)
      scene.add(ground)

      new THREE.TextureLoader().load('./static/img/title.png', (texture) => {
        texture.magFilter = THREE.NearestFilter;
        texture.minFilter = THREE.NearestFilter;
        const titleGeometry = new THREE.PlaneBufferGeometry(256, 64, 40, 10)
        const titleMaterial = new THREE.RawShaderMaterial({
          vertexShader: titleVertexShader,
          fragmentShader: titleFragmentShader,
          transparent: true,
          uniforms: {
            time: {
              type: 'f',
              value: 0
            },
            resolution: {
              type: 'v2',
              value: new THREE.Vector2()
            },
            texture: { type: 't', value: texture },
          },
        })
        title = new THREE.Mesh(titleGeometry, titleMaterial)
        scene.add(title)
      })

      {
        const skyOctahedronGeometry = new THREE.OctahedronBufferGeometry(90, 4)
        const positions = skyOctahedronGeometry.attributes.position.array
        const faceNormalsBase = []
        const centersBase = []
        const delaysBase = []
        for (let i = 0; i < positions.length; i += 9) {
          const normal = computeFaceNormal(
            [positions[i + 0], positions[i + 1], positions[i + 2]],
            [positions[i + 3], positions[i + 4], positions[i + 5]],
            [positions[i + 6], positions[i + 7], positions[i + 8]]
          )
          faceNormalsBase.push(...normal, ...normal, ...normal)
          const center = [
            (positions[i + 0] + positions[i + 3] + positions[i + 6]) / 3,
            (positions[i + 1] + positions[i + 4] + positions[i + 7]) / 3,
            (positions[i + 2] + positions[i + 5] + positions[i + 8]) / 3
          ]
          const delay = Math.random() * 0.5;
          centersBase.push(...center, ...center, ...center)
          delaysBase.push(delay, delay, delay)
        }
        const faceNormals = new Float32Array(faceNormalsBase)
        const centers = new Float32Array(centersBase)
        const delays = new Float32Array(delaysBase)
        skyOctahedronGeometry.setAttribute('faceNormal', new THREE.BufferAttribute(faceNormals, 3))
        skyOctahedronGeometry.setAttribute('center', new THREE.BufferAttribute(centers, 3))
        skyOctahedronGeometry.setAttribute('delay', new THREE.BufferAttribute(delays, 1))
        skyOctahedron = new THREE.Mesh(skyOctahedronGeometry,
          new THREE.RawShaderMaterial({
            uniforms: {
              time: {
                type: 'f',
                value: 0
              },
            },
            vertexShader: skyOctahedronVertexShader,
            fragmentShader: skyOctahedronFragmentShader,
            flatShading: true,
            transparent: true,
            side: THREE.DoubleSide,
            // extensions: {
            //   derivatives: true
            // }
          }))
        scene.add(skyOctahedron)
      }

      renderer = new THREE.WebGLRenderer({ antialias: true })
      // renderer.debug.checkShaderErrors = false
      renderer.setPixelRatio(window.devicePixelRatio)
      renderer.setSize(container.clientWidth, container.clientHeight)
      // renderer.shadowMap.enabled = true
      // const gl = renderer.context
      // gl.getExtension('OES_standard_derivatives')
      // getExtensionWithKnownPrefixes(gl, 'OES_standard_derivatives')
      console.log(renderer.context.getExtension('OES_standard_derivatives'))

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
      now = time * 0.001
      timer = requestAnimationFrame(animate)
      ground.material.uniforms['time'].value = now
      title && (title.material.uniforms['time'].value = now)
      skyOctahedron.material.uniforms['time'].value = now
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
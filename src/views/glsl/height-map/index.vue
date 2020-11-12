<template>
  <div id="canvas" ref="canvas" class="canvas"></div>
</template>

<script>
// 参考引用：https://blog.csdn.net/qq_29814417/article/details/104911497
/* eslint-disable no-alert, no-console */
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import Stats from 'three/examples/jsm/libs/stats.module'
import { GUI } from 'three/examples/jsm/libs/dat.gui.module'
const mapImg = './static/img/earth_1.jpg'
const heightMapImg = './static/img/earth_1-height-map.jpg'
export default {
  data () {
    return {
    }
  },
  computed: {
  },
  mounted () {
    let camera, orbitControl, scene, renderer, stats
    let gui
    const $canvasContainer = this.$refs.canvas
    function init () {
      const earthShader = {
        vertexShader: `
        varying vec4 v_color; // 用来存储当前顶点颜色
        varying vec2 v_uv; // UV
        uniform float u_height; // 生成的高度
        uniform float u_radius; // 半径
        uniform sampler2D u_bump; // 高度图
        // 插值计算
        float lerp(float x, float y, float t) {
          return (1.0 - t) * x + t * y;
        }
        // 获得当前向量与中心点的距离
        float glength(vec3 p) {
          return sqrt(p.x * p.x + p.y * p.y + p.z * p.z);
        }
        // 传入当前向量 需要返回的长度
        vec3 setLength(vec3 p, float length) {
          vec3 c_position = p;
          float scale = length / glength(c_position);
          c_position.x *= scale;
          c_position.y *= scale;
          c_position.z *= scale;
          return c_position;
        }
        void main() {
          v_uv = uv; // uv
          v_color = texture2D(u_bump, uv); // 生成当前高度信息
          float c_height = v_color.r * u_height; // 生成当前的高度 当前的灰度r值 * 基础高度
          vec3 vposition = setLength(position, u_radius + c_height); // 生成新的向量 离中心距离为当前基础半径+生成的高度
          // 传递 position
          vec4 mPosition = modelViewMatrix * vec4(vposition, 1.0); 
          gl_Position = projectionMatrix * mPosition;
        }
      `,
        fragmentShader: `
        uniform float u_opacity; // 透明度
        uniform vec3 u_color; // 基础颜色
        varying vec2 v_uv; // UV
        uniform sampler2D u_map; // 基础材质
        void main() {
          gl_FragColor = vec4(u_color, u_opacity) * texture2D(u_map, v_uv);
        }
    `
      }
      // threejs
      const options = {
        radius: 100, // 地球的半径
        segments: 640, // 地球的分段数 数量越高 地球精度越高
        map: mapImg, // 地球材质
        bump: heightMapImg, // 生成高度材质
        maxHeight: 10 // 高度图最高高度
      }
      scene = new THREE.Scene()
      camera = new THREE.PerspectiveCamera(
        50,
        window.innerWidth / window.innerHeight,
        1,
        2000
      )
      camera.up.x = 0
      camera.up.y = 1
      camera.up.z = 0
      camera.position.x = 0
      camera.position.y = 0
      camera.position.z = 300
      camera.lookAt(0, 0, 0)

      // light
      const dirLight = new THREE.DirectionalLight(0xffffff)
      dirLight.position.set(200, 200, 1000).normalize()

      camera.add(dirLight)
      camera.add(dirLight.target)

      // 生成球类几何
      const geometry = new THREE.SphereBufferGeometry(options.radius, options.segments, options.segments);
      // 使用自定义着色器
      const material = new THREE.ShaderMaterial({
        uniforms: {
          u_radius: {
            value: options.radius // 半径
          },
          u_height: {
            value: options.maxHeight // 生成的高度
          },
          u_map: {
            value: new THREE.TextureLoader().load(options.map) // 贴图
          },
          u_bump: {
            value: new THREE.TextureLoader().load(options.bump) // 高度图
          },
          u_color: {
            value: new THREE.Color('rgb(255, 255, 255)')
          },
          u_opacity: {
            value: 1.0
          }
        },
        transparent: true,
        vertexShader: earthShader.vertexShader, // 顶点着色器
        fragmentShader: earthShader.fragmentShader, // 片元着色器
      })
      const earth = new THREE.Mesh(geometry, material)
      earth.rotation.x = THREE.Math.degToRad(35) // 中国
      earth.rotation.y = THREE.Math.degToRad(170) // 中国
      scene.add(earth)

      // 渲染器
      renderer = new THREE.WebGLRenderer({
        antialias: true
      })
      renderer.setPixelRatio(window.devicePixelRatio)
      renderer.setSize($canvasContainer.clientWidth, $canvasContainer.clientHeight)
      $canvasContainer.appendChild(renderer.domElement)

      // 盘旋控制
      orbitControl = new OrbitControls(camera, renderer.domElement)
      orbitControl.minDistrance = 20
      orbitControl.maxDistrance = 50
      orbitControl.maxPolarAngle = Math.PI / 2

      // stats
      stats = new Stats()
      stats.domElement.style.position = 'absolute'
      stats.domElement.style.top = '0px'
      $canvasContainer.appendChild(stats.domElement)

      // gui
      GUI.TEXT_CLOSED = '关闭控制面板'
      GUI.TEXT_OPEN = '打开控制面板'
      gui = gui || new GUI()
      gui.width = 300
      gui.domElement.style.userSelect = 'none'

      const fl = gui.addFolder('地球参数')
      fl.add(options, 'radius', 50, 200, 1)
        .name('地球半径')
        .onChange(function () {
          earth.geometry.parameters.radius = options.radius
          earth.material.uniforms.u_radius.value = options.radius
        })

      fl.add(options, 'maxHeight', 0, 40, 0.2)
        .name('高度图最大高度')
        .onChange(function () {
          earth.material.uniforms.u_height.value = options.maxHeight
        })
      fl.open()
      console.log(gui)

      // resize
      window.addEventListener('resize', onWindowResize, false)
    }

    function onWindowResize () {
      camera.aspect = window.innerWidth / window.innerHeight
      camera.updateProjectionMatrix()
      renderer.setSize(window.innerWidth, window.innerHeight)

    }

    function render () {
      stats.update()
      renderer.render(scene, camera)
    }

    // 动画
    function animate () {
      requestAnimationFrame(animate)
      render()
    }

    init()
    animate()
  },
  beforeDestroy () {
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
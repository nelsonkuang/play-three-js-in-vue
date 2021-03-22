<template>
  <div
    id="canvas"
    ref="canvas"
    class="canvas"
  ></div>
</template>

<script>
// 参考引用：https://ykob.github.io/sketch-threejs/
/* eslint-disable no-alert, no-console */
import * as THREE from 'three'
import Mover from './core/Mover'
import Points from './core/Points'
import ForcePointLight from './core/ForcePointLight'
import ForcePerspectiveCamera from './core/ForcePerspectiveCamera'
import { getPolarCoord, radians, randomInt } from '@/utils/math-ex'
import { debounce, normalizeVector2 } from '@/utils/tools'
import pointsVertexShader from './core/shaders/points.vs.glsl'
import pointsFragmentShader from './core/shaders/points.fs.glsl'

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

    renderer = new THREE.WebGL1Renderer({ antialias: false })
    renderer.setPixelRatio(window.devicePixelRatio)
    renderer.setSize(container.clientWidth, container.clientHeight)

    container.appendChild(renderer.domElement)

    scene = new THREE.Scene()
    camera = new ForcePerspectiveCamera(35, container.clientWidth / container.clientHeight, 1, 10000)

    // process for this sketch
    const moversNum = 10000 // 控制生成点的个数来构成火的效果
    const movers = []
    const points = new Points()
    const light = new ForcePointLight(0xff6600, 1, 1800, 1) // hex, intensity, distance, decay
    const positions = new Float32Array(moversNum * 3)
    const colors = new Float32Array(moversNum * 3)
    const opacities = new Float32Array(moversNum)
    const sizes = new Float32Array(moversNum)
    const gravity = new THREE.Vector3(0, 0.1, 0)

    let bg = null
    let lastTimeActivate = Date.now()
    let isDraged = false

    function updateMover () {
      let i;
      for (i = 0; i < movers.length; ++i) {
        const mover = movers[i]
        if (mover.isActive) {
          mover.time++
          mover.applyForce(gravity)
          mover.applyDrag(0.01)
          mover.updateVelocity()
          if (mover.time > 50) {
            mover.size -= 0.7
            mover.a -= 0.009
          }
          if (mover.a <= 0) {
            mover.init(new THREE.Vector3(0, 0, 0))
            mover.time = 0
            mover.a = 0.0
            mover.inactivate()
          }
        }
        positions[i * 3 + 0] = mover.velocity.x - points.velocity.x
        positions[i * 3 + 1] = mover.velocity.y - points.velocity.y
        positions[i * 3 + 2] = mover.velocity.z - points.velocity.z
        opacities[i] = mover.a
        sizes[i] = mover.size
      }
      points.updatePoints()
    }

    function activateMover () {
      let count = 0;
      const now = Date.now()
      if (now - lastTimeActivate > 10) {
        let i
        for (i = 0; i < movers.length; ++i) {
          const mover = movers[i]
          if (mover.isActive) continue
          const rad1 = radians(Math.log(randomInt(0, 256)) / Math.log(256) * 260)
          const rad2 = radians(randomInt(0, 360))
          const range = (1 - Math.log(randomInt(32, 256)) / Math.log(256)) * 12
          const vector = new THREE.Vector3()
          const force = getPolarCoord(rad1, rad2, range)
          vector.add(points.velocity)
          mover.activate()
          mover.init(vector)
          mover.applyForce(force)
          mover.a = 0.2
          mover.size = Math.pow(12 - range, 2) * randomInt(1, 24) / 10
          ++count
          if (count >= 6) break
        }
        lastTimeActivate = Date.now()
      }
    }

    function movePoints (vector) {
      const y = vector.y * container.clientHeight / 3
      const z = vector.x * container.clientWidth / -3
      points.anchor.y = y
      points.anchor.z = z
      light.force.anchor.y = y
      light.force.anchor.z = z
    }

    function createTexture () {
      const canvas2D = document.createElement('canvas')
      const ctx = canvas2D.getContext('2d')
      let grad = null
      let texture = null

      canvas2D.width = 200
      canvas2D.height = 200
      grad = ctx.createRadialGradient(100, 100, 20, 100, 100, 100)
      grad.addColorStop(0.2, 'rgba(255, 255, 255, 1)')
      grad.addColorStop(0.5, 'rgba(255, 255, 255, 0.3)')
      grad.addColorStop(1.0, 'rgba(255, 255, 255, 0)')
      ctx.fillStyle = grad
      ctx.arc(100, 100, 100, 0, Math.PI / 180, true)
      ctx.fill()

      texture = new THREE.Texture(canvas2D)
      texture.minFilter = THREE.NearestFilter
      texture.needsUpdate = true
      return texture
    }

    function createBackground () {
      const geometry = new THREE.OctahedronGeometry(1500, 3)
      const material = new THREE.MeshPhongMaterial({
        color: 0xffffff,
        flatShading: true,
        side: THREE.BackSide
      })
      return new THREE.Mesh(geometry, material)
    }

    function initSketch () {
      let i
      for (i = 0; i < moversNum; i++) {
        const mover = new Mover()
        const h = randomInt(0, 45)
        const s = randomInt(60, 90)
        const color = new THREE.Color('hsl(' + h + ', ' + s + '%, 50%)')

        mover.init(new THREE.Vector3(randomInt(-100, 100), 0, 0))
        movers.push(mover)
        positions[i * 3 + 0] = mover.velocity.x
        positions[i * 3 + 1] = mover.velocity.y
        positions[i * 3 + 2] = mover.velocity.z
        color.toArray(colors, i * 3)
        opacities[i] = mover.a
        sizes[i] = mover.size
      }
      points.init({
        scene: scene,
        vs: pointsVertexShader,
        fs: pointsFragmentShader,
        positions: positions,
        colors: colors,
        opacities: opacities,
        sizes: sizes,
        texture: createTexture(),
        blending: THREE.AdditiveBlending
      })
      scene.add(light)
      bg = createBackground()
      scene.add(bg)
      camera.setPolarCoord(radians(25), 0, 1000)
      light.setPolarCoord(radians(25), 0, 200)
    }

    // common process
    const resizeWindow = () => {
      camera.aspect = container.clientWidth / container.clientHeight
      camera.updateProjectionMatrix()
      renderer.setSize(container.clientWidth, container.clientHeight)
    }

    const render = () => {
      points.applyHook(0, 0.08)
      points.applyDrag(0.2)
      points.updateVelocity()
      light.force.applyHook(0, 0.08)
      light.force.applyDrag(0.2)
      light.force.updateVelocity()
      light.updatePosition()
      activateMover()
      updateMover()
      camera.force.position.applyHook(0, 0.004)
      camera.force.position.applyDrag(0.1)
      camera.force.position.updateVelocity()
      camera.updatePosition()
      camera.lookAtCenter()
      renderer.render(scene, camera)
    }

    const renderLoop = () => {
      render()
      timer = requestAnimationFrame(renderLoop)
    }

    const bindDomEvents = () => {
      const vectorTouchStart = new THREE.Vector2()
      const vectorTouchMove = new THREE.Vector2()
      const vectorTouchEnd = new THREE.Vector2()

      const touchStart = (x, y) => {
        vectorTouchStart.set(x, y)
        normalizeVector2(vectorTouchStart, container.clientWidth, container.clientHeight)
        movePoints(vectorTouchStart)
        isDraged = true
      }
      const touchMove = (x, y) => {
        vectorTouchMove.set(x, y)
        normalizeVector2(vectorTouchMove, container.clientWidth, container.clientHeight)
        if (isDraged) {
          movePoints(vectorTouchMove)
        }
      }
      const touchEnd = (x, y) => {
        vectorTouchEnd.set(x, y)
        isDraged = false
        points.anchor.set(0, 0, 0)
        light.force.anchor.set(0, 0, 0)
      }
      const mouseOut = () => {
        vectorTouchEnd.set(0, 0)
        isDraged = false
        points.anchor.set(0, 0, 0)
        light.force.anchor.set(0, 0, 0)
      }

      window.addEventListener('resize', debounce(() => {
        resizeWindow()
      }), 1000)
      container.addEventListener('mousedown', function (event) {
        event.preventDefault()
        touchStart(event.clientX, event.clientY, false)
      })
      container.addEventListener('mousemove', function (event) {
        event.preventDefault()
        touchMove(event.clientX, event.clientY, false)
      })
      container.addEventListener('mouseup', function (event) {
        event.preventDefault()
        touchEnd(event.clientX, event.clientY, false)
      })
      container.addEventListener('touchstart', function (event) {
        event.preventDefault()
        touchStart(event.touches[0].clientX, event.touches[0].clientY, true)
      })
      container.addEventListener('touchmove', function (event) {
        event.preventDefault()
        touchMove(event.touches[0].clientX, event.touches[0].clientY, true)
      })
      container.addEventListener('touchend', function (event) {
        event.preventDefault()
        touchEnd(event.changedTouches[0].clientX, event.changedTouches[0].clientY, true)
      })
      window.addEventListener('mouseout', function () {
        event.preventDefault()
        mouseOut()
      })
    }

    const init = () => {
      renderer.setSize(container.clientWidth, container.clientHeight);
      renderer.setClearColor(0x000000, 1.0)
      camera.position.set(1000, 1000, 1000)
      camera.lookAt(new THREE.Vector3())

      bindDomEvents()
      initSketch()
      resizeWindow()
      renderLoop()
    }

    init()
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
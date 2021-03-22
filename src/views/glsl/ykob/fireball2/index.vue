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
import { debounce } from '@/utils/tools'

import WebGLContent from './core/WebGLContent'

let timer = null
export default {
  data () {
    return {
    }
  },
  computed: {
  },
  async mounted () {
    let container = this.$refs.canvas
    const webglContent = new WebGLContent()
    const resolution = new THREE.Vector2()
    const resizeWindow = () => {
      resolution.set(container.clientWidth, container.clientHeight)
      webglContent.resize(resolution)
    }
    const bindDomEvents = () => {
      const touchstart = (e) => {
        webglContent.touchStart(e, resolution);
      }
      const touchmove = (e) => {
        webglContent.touchMove(e, resolution);
      }
      const touchend = () => {
        webglContent.touchEnd()
      }
      container.addEventListener('mousedown', touchstart, { passive: false })
      window.addEventListener('mousemove', touchmove, { passive: false })
      window.addEventListener('mouseup', touchend)
      container.addEventListener('touchstart', touchstart, { passive: false })
      window.addEventListener('touchmove', touchmove, { passive: false })
      window.addEventListener('touchend', touchend)
      window.addEventListener('blur', () => {
        webglContent.pause()
      })
      window.addEventListener('focus', () => {
        webglContent.play()
      })
      window.addEventListener('resize', debounce(resizeWindow, 100))
    }
    const update = () => {
      webglContent.update()
      timer = requestAnimationFrame(update)
    }
    await webglContent.start(container)

    bindDomEvents()
    resizeWindow()
    webglContent.play()
    update()
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
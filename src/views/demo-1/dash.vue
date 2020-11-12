<template>
  <div>
    <h1>{{ $route.meta.title }}</h1>
    <div class="container">
      <canvas id="canvas" ref="canvas" class="canvas" width="340" height="500"></canvas>
    </div>
  </div>
</template>

<script>
/* eslint-disable no-alert, no-console */
import Path from '../../utils/classes/Path'
import { getDomOffset } from '../../utils/tools'
const curve = {
  canvas: null,
  path: new Path(),
  p0: [80, 50],
  p1: [100, 130],
  p2: [200, 150],
  p3: [250, 90],
  r: 20,
  currentPos: {
    x: 0,
    y: 0
  },
  animationID: null
}
export default {
  data () {
    return {
    }
  },
  computed: {
  },
  mounted () {
    this.initCavas()
  },
  beforeDestroy () {
    cancelAnimationFrame(curve.animationID)
  },
  methods: {
    initCavas () {
      curve.canvas = this.$refs.canvas
      const draw = () => {
        const ctx = curve.canvas.getContext('2d')
        const cWidth = Number(curve.canvas.getAttribute('width'))
        const cHeight = Number(curve.canvas.getAttribute('height'))
        ctx.clearRect(0, 0, cWidth, cHeight)
        ctx.strokeStyle = '#000000'
        const { p0, p1, p2, p3, r } = curve
        const p = curve.path
        p.beginPath(ctx)
        // 画线
        p.setLineDash([3, 3]) // 设置为虚线
        p.moveTo(p0[0], p0[1])
        p.bezierCurveTo(p1[0], p1[1], p2[0], p2[1], p3[0], p3[1])
        p.stroke(ctx)
        p.closePath()
        p.beginPath(ctx)
        p.setLineDash(null) // 设置为实线
        ctx.strokeStyle = '#cccccc'
        p.moveTo(p0[0], p0[1])
        p.lineTo(p1[0], p1[1])
        p.moveTo(p3[0], p3[1])
        p.lineTo(p2[0], p2[1])
        // 画点
        p.stroke(ctx)
        p.closePath()
        p.beginPath(ctx)
        ctx.strokeStyle = '#000000'
        p.moveTo(p0[0] + r, p0[1])
        p.arc(p0[0], p0[1], r, 0, Math.PI * 2, false)
        p.moveTo(p3[0] + r, p3[1])
        p.arc(p3[0], p3[1], r, 0, Math.PI * 2, false)
        p.moveTo(p1[0] + r, p1[1])
        p.arc(p1[0], p1[1], r, 0, Math.PI * 2, false)
        p.moveTo(p2[0] + r, p2[1])
        p.arc(p2[0], p2[1], r, 0, Math.PI * 2, false)

        p.stroke(ctx)
        p.closePath()

        // 画文字
        ctx.font = '400 12px "Hiragino Sans GB W3","Microsoft YaHei",sans-serif'
        ctx.textBaseline = 'middle'
        ctx.fillStyle = '#333333'
        ctx.fillText(`(${~~p0[0]}, ${~~p0[1]})`, p0[0] + 30, p0[1])
        ctx.fillText(`(${~~p1[0]}, ${~~p1[1]})`, p1[0] + 30, p1[1])
        ctx.fillText(`(${~~p2[0]}, ${~~p2[1]})`, p2[0] + 30, p2[1])
        ctx.fillText(`(${~~p3[0]}, ${~~p3[1]})`, p3[0] + 30, p3[1])
      }
      const bindEvents = () => {
        const This = curve
        const offset = getDomOffset(This.canvas)
        const supportedTouch = window.hasOwnProperty('ontouchstart')
        let isDraging = false
        let dragingName = ''
        if (supportedTouch) {
          This.canvas.ontouchstart = function (event) {
            This.currentPos = { x: event.touches[0].pageX - offset.left, y: event.touches[0].pageY - offset.top }
            const hoverDisplayObject = getHoverDisplayObject()
            if (hoverDisplayObject) {
              let p = []
              p[0] = This.currentPos.x
              p[1] = This.currentPos.y
              dragingName = hoverDisplayObject.name
              This[dragingName] = p
              isDraging = true
            }
          }
          This.canvas.ontouchmove = function (event) {
            event.preventDefault()
            This.currentPos = { x: event.touches[0].pageX - offset.left, y: event.touches[0].pageY - offset.top }
            if (isDraging && dragingName) {
              let p = []
              p[0] = This.currentPos.x
              p[1] = This.currentPos.y
              This[dragingName] = p
            }
          }
          This.canvas.ontouchend = function () {
            isDraging = false
            dragingName = ''
          }
        } else {
          This.canvas.onmousemove = function (event) {
            This.currentPos = { x: event.pageX - offset.left, y: event.pageY - offset.top }
            if (isDraging && dragingName) {
              let p = []
              p[0] = This.currentPos.x
              p[1] = This.currentPos.y
              This[dragingName] = p
            }
          }
          This.canvas.onmousedown = function (event) {
            This.currentPos = { x: event.pageX - offset.left, y: event.pageY - offset.top }
            const hoverDisplayObject = getHoverDisplayObject()
            if (hoverDisplayObject) {
              let p = []
              p[0] = This.currentPos.x
              p[1] = This.currentPos.y
              dragingName = hoverDisplayObject.name
              This[dragingName] = p
              isDraging = true
            }
          }
          This.canvas.onmouseup = function () {
            isDraging = false
            dragingName = ''
          }
          This.canvas.onmouseleave = function () {
            isDraging = false
            dragingName = ''
          }
        }
      }
      const getDisplayObjects = () => {
        const { p0, p1, p2, p3, r } = curve
        return {
          p0: {
            name: 'p0',
            x: p0[0] - r,
            y: p0[1] - r,
            width: 2 * r,
            height: 2 * r,
            zIndex: 0
          },
          p1: {
            name: 'p1',
            x: p1[0] - r,
            y: p1[1] - r,
            width: 2 * r,
            height: 2 * r,
            zIndex: 1
          },
          p2: {
            name: 'p2',
            x: p2[0] - r,
            y: p2[1] - r,
            width: 2 * r,
            height: 2 * r,
            zIndex: 2
          },
          p3: {
            name: 'p3',
            x: p3[0] - r,
            y: p3[1] - r,
            width: 2 * r,
            height: 2 * r,
            zIndex: 3
          }
        }
      }
      const getHoverDisplayObject = () => {
        const { currentPos } = curve
        const { p0, p1, p2, p3 } = getDisplayObjects()
        if (currentPos.x > p0.x && currentPos.x < p0.x + p0.width && currentPos.y > p0.y && currentPos.y < p0.y + p0.height) {
          return p0
        } else if (currentPos.x > p1.x && currentPos.x < p1.x + p1.width && currentPos.y > p1.y && currentPos.y < p1.y + p1.height) {
          return p1
        } else if (currentPos.x > p2.x && currentPos.x < p2.x + p2.width && currentPos.y > p2.y && currentPos.y < p2.y + p2.height) {
          return p2
        } else if (currentPos.x > p3.x && currentPos.x < p3.x + p3.width && currentPos.y > p3.y && currentPos.y < p3.y + p3.height) {
          return p3
        } else {
          return null
        }
      }
      const update = () => {
        const hoverDisplayObject = getHoverDisplayObject()
        if (hoverDisplayObject) {
          curve.canvas.classList.add('hover')
        } else {
          curve.canvas.classList.remove('hover')
        }
        draw()
        curve.animationID = requestAnimationFrame(update)
      }

      bindEvents()
      update()
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
.canvas {
  border: 1px dashed #ddd;
}
.canvas.hover {
  cursor: move;
}
</style>

<template>
  <div id="canvas" ref="canvas" class="canvas"></div>
</template>

<script>
// 参考引用：https://github.com/mrdoob/three.js/blob/master/examples/misc_animation_keys.html
/* eslint-disable no-alert, no-console */
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import Stats from 'three/examples/jsm/libs/stats.module'
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
    let clock
    let scene, camera, renderer, mixer

    init()
    animate()
    function init () {
      scene = new THREE.Scene()
      //
      camera = new THREE.PerspectiveCamera(40, container.clientWidth / container.clientHeight, 1, 1000)
      camera.position.set(25, 25, 50)
      camera.lookAt(scene.position)
      //
      const axesHelper = new THREE.AxesHelper(10)
      scene.add(axesHelper)
      //
      const geometry = new THREE.BoxBufferGeometry(5, 5, 5)
      const material = new THREE.MeshBasicMaterial({ color: 0xffffff, transparent: true })
      const mesh = new THREE.Mesh(geometry, material)
      scene.add(mesh)
      // create a keyframe track (i.e. a timed sequence of keyframes) for each animated property
      // Note: the keyframe track type should correspond to the type of the property being animated

      // POSITION
      const positionKF = new THREE.VectorKeyframeTrack('.position', [0, 1, 2], [0, 0, 0, 5, 0, 0, 0, 0, 0])

      // SCALE
      const scaleKF = new THREE.VectorKeyframeTrack('.scale', [0, 1, 2], [1, 1, 1, 2, 2, 2, 1, 1, 1])

      // ROTATION
      // Rotation should be performed using quaternions, using a THREE.QuaternionKeyframeTrack
      // Interpolating Euler angles (.rotation property) can be problematic and is currently not supported

      // set up rotation about x axis
      const xAxis = new THREE.Vector3(1, 0, 0)

      const qInitial = new THREE.Quaternion().setFromAxisAngle(xAxis, 0)
      const qFinal = new THREE.Quaternion().setFromAxisAngle(xAxis, Math.PI)
      const quaternionKF = new THREE.QuaternionKeyframeTrack('.quaternion', [0, 1, 2], [qInitial.x, qInitial.y, qInitial.z, qInitial.w, qFinal.x, qFinal.y, qFinal.z, qFinal.w, qInitial.x, qInitial.y, qInitial.z, qInitial.w])

      // COLOR
      const colorKF = new THREE.ColorKeyframeTrack('.material.color', [0, 1, 2], [1, 0, 0, 0, 1, 0, 0, 0, 1], THREE.InterpolateDiscrete)

      // OPACITY
      const opacityKF = new THREE.NumberKeyframeTrack('.material.opacity', [0, 1, 2], [1, 0.2, 1])

      // create an animation sequence with the tracks
      // If a negative time value is passed, the duration will be calculated from the times of the passed tracks array
      const clip = new THREE.AnimationClip('Action', 2, [scaleKF, positionKF, quaternionKF, colorKF, opacityKF])

      // setup the THREE.AnimationMixer
      mixer = new THREE.AnimationMixer(mesh)

      // create a ClipAction and set it to play
      const clipAction = mixer.clipAction(clip)
      clipAction.play()

      //
      renderer = new THREE.WebGLRenderer({ antialias: true })
      renderer.setPixelRatio(window.devicePixelRatio)
      renderer.setSize(container.clientWidth, container.clientHeight)
      container.appendChild(renderer.domElement)

      //
      stats = new Stats()
      container.appendChild(stats.dom)

      new OrbitControls(camera, renderer.domElement)

      //
      clock = new THREE.Clock()

      //
      window.addEventListener('resize', onWindowResize, false)
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
      render()
    }

    function render () {
      const delta = clock.getDelta()
      if (mixer) {
        mixer.update(delta)
      }

      renderer.render(scene, camera)
      stats.update()
    }
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
import Force3 from './Force3'
import { getPolarCoord } from '@/utils/math-ex'
const THREE = require('three')

class ForcePerspectiveCamera extends THREE.PerspectiveCamera {
  nelType = 'ForcePerspectiveCamera'

  constructor(fov, aspect, near, far) {
    super(fov, aspect, near, far)
    this.force = {
      position: new Force3(),
      look: new Force3(),
    }
    this.up.set(0, 1, 0)
  }

  updatePosition () {
    this.position.copy(this.force.position.velocity)
  }

  updateLook () {
    this.lookAt(
      this.force.look.velocity.x,
      this.force.look.velocity.y,
      this.force.look.velocity.z
    )
  }

  reset () {
    this.setPolarCoord()
    this.lookAtCenter()
  }

  applyDrag (value) {
    const force = this.acceleration.clone()
    force.multiplyScalar(-1)
    force.normalize()
    force.multiplyScalar(this.acceleration.length() * value)
    this.applyForce(force)
  }

  resize (width, height) {
    this.aspect = width / height
    this.updateProjectionMatrix()
  }

  setPolarCoord (rad1, rad2, range) {
    this.force.position.anchor.copy(getPolarCoord(rad1, rad2, range))
  }

  lookAtCenter () {
    this.lookAt(0, 0, 0)
  }
}
export default ForcePerspectiveCamera

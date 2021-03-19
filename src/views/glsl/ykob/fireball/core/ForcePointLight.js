import Force3 from './Force3'
import { getPolarCoord } from '@/utils/math-ex'
const THREE = require('three')

class ForcePointLight extends THREE.PointLight {
  nelType = 'ForcePointLight'

  constructor(hex, intensity, distance, decay) {
    super(hex, intensity, distance, decay)
    this.force = new Force3()
  }

  updatePosition () {
    this.position.copy(this.force.velocity)
  }

  setPolarCoord (rad1, rad2, range) {
    this.position.copy(getPolarCoord(rad1, rad2, range))
  }
}
export default ForcePointLight

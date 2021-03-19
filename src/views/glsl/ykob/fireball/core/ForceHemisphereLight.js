import Force3 from './Force3'
import { getPolarCoord } from '@/utils/math-ex'
const THREE = require('three')

class ForceHemisphereLight extends THREE.HemisphereLight {
  nelType = 'ForceHemisphereLight'

  constructor(hex1, hex2, intensity) {
    super(hex1, hex2, intensity)
    this.force = new Force3()
  }

  updatePosition () {
    this.position.copy(this.force.velocity)
  }

  setPolarCoord (rad1, rad2, range) {
    this.position.copy(getPolarCoord(rad1, rad2, range))
  }
}
export default ForceHemisphereLight

const THREE = require('three')

class Force3 {
  nelType = 'Force3'

  constructor() {
    this.velocity = new THREE.Vector3()
    this.acceleration = new THREE.Vector3()
    this.anchor = new THREE.Vector3()
    this.mass = 1
  }

  updateVelocity () {
    this.acceleration.divideScalar(this.mass)
    this.velocity.add(this.acceleration)
  }

  applyForce (vector) {
    this.acceleration.add(vector)
  }

  applyFriction (mu, normal) {
    const force = this.acceleration.clone()
    if (!normal) normal = 1
    force.multiplyScalar(-1)
    force.normalize()
    force.multiplyScalar(mu)
    this.applyForce(force)
  }

  applyDrag (value) {
    const force = this.acceleration.clone()
    force.multiplyScalar(-1)
    force.normalize()
    force.multiplyScalar(this.acceleration.length() * value)
    this.applyForce(force)
  }

  applyHook (restLength, k) {
    const force = this.velocity.clone().sub(this.anchor)
    const distance = force.length() - restLength
    force.normalize()
    force.multiplyScalar(-1 * k * distance)
    this.applyForce(force)
  }
}
export default Force3

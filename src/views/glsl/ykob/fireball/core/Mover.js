import Force3 from './Force3'

class Mover extends Force3 {
  nelType = 'Mover'
  constructor() {
    super()
    this.size = 0
    this.time = 0
    this.isActive = false
  }

  init (vector) {
    this.velocity = vector.clone()
    this.anchor = vector.clone()
    this.acceleration.set(0, 0, 0)
    this.time = 0
  }

  activate () {
    this.isActive = true
  }

  inactivate () {
    this.isActive = false
  }
}

export default Mover
const glsl = [
  {
    path: '/glsl/height-map',
    name: 'HeightMap',
    component: () => import('@/views/glsl/height-map/index'),
    meta: {
      title: 'Three.js 实战 地球贴图 高度图'
    }
  },
  {
    path: '/glsl/diamond',
    name: 'Diamond',
    component: () => import('@/views/glsl/diamond/index'),
    meta: {
      title: 'Three.js 实战 开源实例魔改 钻石'
    }
  },
  {
    path: '/glsl/image-effect/emboss',
    name: 'Emboss',
    component: () => import('@/views/glsl/image-effect/emboss/index'),
    meta: {
      title: 'glsl 实战 浮雕效果'
    }
  },
  {
    path: '/glsl/diamond-ii',
    name: 'DiamondII',
    component: () => import('@/views/glsl/diamond-ii/index'),
    meta: {
      title: 'Three.js 实战 愤怒的钻石'
    }
  }
]
export default glsl
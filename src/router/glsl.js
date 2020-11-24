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
    path: '/glsl/image-effect/gray',
    name: 'Gray',
    component: () => import('@/views/glsl/image-effect/gray/index'),
    meta: {
      title: 'glsl 入门效果 灰度图 + 图像颠倒'
    }
  },
  {
    path: '/glsl/image-effect/emboss',
    name: 'Emboss',
    component: () => import('@/views/glsl/image-effect/emboss/index'),
    meta: {
      title: 'glsl 入门效果 浮雕效果'
    }
  },
  {
    path: '/glsl/image-effect/mosaic',
    name: 'Mosaic',
    component: () => import('@/views/glsl/image-effect/mosaic/index'),
    meta: {
      title: 'glsl 入门效果 马赛克效果'
    }
  },
  {
    path: '/glsl/image-effect/mosaic-point',
    name: 'MosaicPoint',
    component: () => import('@/views/glsl/image-effect/mosaic-point/index'),
    meta: {
      title: 'glsl 入门效果 圆形马赛克效果'
    }
  },
  {
    path: '/glsl/image-effect/blur',
    name: 'Blur',
    component: () => import('@/views/glsl/image-effect/blur/index'),
    meta: {
      title: 'glsl 进阶效果 锐化模糊效果'
    }
  },
  {
    path: '/glsl/image-effect/edge',
    name: 'Edge',
    component: () => import('@/views/glsl/image-effect/edge/index'),
    meta: {
      title: 'glsl 进阶效果 铅笔描边效果'
    }
  },
  {
    path: '/glsl/image-effect/hdr-blow',
    name: 'HdrBlow',
    component: () => import('@/views/glsl/image-effect/hdr-blow/index'),
    meta: {
      title: 'glsl 高级效果 伪 HDR / Blow'
    }
  },
  {
    path: '/glsl/image-effect/water-filter',
    name: 'WaterFilter',
    component: () => import('@/views/glsl/image-effect/water-filter/index'),
    meta: {
      title: 'glsl 高级效果 水彩化'
    }
  },
  {
    path: '/glsl/image-effect/rotate',
    name: 'Rotate',
    component: () => import('@/views/glsl/image-effect/rotate/index'),
    meta: {
      title: 'glsl 高级效果 旋转效果'
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
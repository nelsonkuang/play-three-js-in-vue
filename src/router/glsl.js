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
    path: '/glsl/image-effect/fog',
    name: 'Fog',
    component: () => import('@/views/glsl/image-effect/fog/index'),
    meta: {
      title: 'glsl 进阶效果 雾效果'
    }
  },
  {
    path: '/glsl/image-effect/vignette',
    name: 'Vignette',
    component: () => import('@/views/glsl/image-effect/vignette/index'),
    meta: {
      title: 'glsl 进阶效果 小插图效果'
    }
  },
  {
    path: '/glsl/image-effect/scan-line',
    name: 'ScanLine',
    component: () => import('@/views/glsl/image-effect/scan-line/index'),
    meta: {
      title: 'glsl 进阶效果 扫描线效果'
    }
  },
  {
    path: '/glsl/image-effect/pixelate',
    name: 'Pixelate',
    component: () => import('@/views/glsl/image-effect/pixelate/index'),
    meta: {
      title: 'glsl 进阶效果 像素化效果'
    }
  },
  {
    path: '/glsl/image-effect/scale',
    name: 'Scale',
    component: () => import('@/views/glsl/image-effect/scale/index'),
    meta: {
      title: 'glsl 进阶效果 缩放'
    }
  },
  {
    path: '/glsl/image-effect/flash',
    name: 'Flash',
    component: () => import('@/views/glsl/image-effect/flash/index'),
    meta: {
      title: 'glsl 进阶效果 闪白'
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
    path: '/glsl/image-effect/frosted-glass',
    name: 'FrostedGlass',
    component: () => import('@/views/glsl/image-effect/frosted-glass/index'),
    meta: {
      title: 'glsl 高级效果 Windows7 Aero 的毛玻璃 / 晶体效果'
    }
  },
  {
    path: '/glsl/image-effect/mask',
    name: 'Mask',
    component: () => import('@/views/glsl/image-effect/mask/index'),
    meta: {
      title: 'glsl 高级效果 遮罩特效'
    }
  },
  {
    path: '/glsl/image-effect/weak-mask',
    name: 'WeakMask',
    component: () => import('@/views/glsl/image-effect/weak-mask/index'),
    meta: {
      title: 'glsl 高级效果 灵魂出窍'
    }
  },
  {
    path: '/glsl/image-effect/debounce',
    name: 'Debounce',
    component: () => import('@/views/glsl/image-effect/debounce/index'),
    meta: {
      title: 'glsl 高级效果 抖动'
    }
  },
  {
    path: '/glsl/image-effect/jitter',
    name: 'Jitter',
    component: () => import('@/views/glsl/image-effect/jitter/index'),
    meta: {
      title: 'glsl 高级效果 毛刺'
    }
  },
  {
    path: '/glsl/image-effect/flame',
    name: 'Flame',
    component: () => import('@/views/glsl/image-effect/flame/index'),
    meta: {
      title: 'glsl 高级效果 火焰'
    }
  },
  {
    path: '/glsl/image-effect/fantasy',
    name: 'Fantasy',
    component: () => import('@/views/glsl/image-effect/fantasy/index'),
    meta: {
      title: 'glsl 高级效果 幻觉'
    }
  },
  {
    path: '/glsl/image-effect/sin-wave-mask',
    name: 'SinWaveMask',
    component: () => import('@/views/glsl/image-effect/sin-wave-mask/index'),
    meta: {
      title: 'glsl 高级效果 正弦波遮罩效果'
    }
  },
  {
    path: '/glsl/image-effect/snow',
    name: 'Snow',
    component: () => import('@/views/glsl/image-effect/snow/index'),
    meta: {
      title: 'glsl 高级效果 雪花飞舞'
    }
  },
  {
    path: '/glsl/image-effect/flower',
    name: 'Flower',
    component: () => import('@/views/glsl/image-effect/flower/index'),
    meta: {
      title: 'glsl 高级效果 落花'
    }
  },
  {
    path: '/glsl/image-effect/particle',
    name: 'Particle',
    component: () => import('@/views/glsl/image-effect/particle/index'),
    meta: {
      title: 'glsl 高级效果 旋转粒子'
    }
  },
  {
    path: '/glsl/diamond-ii',
    name: 'DiamondII',
    component: () => import('@/views/glsl/diamond-ii/index'),
    meta: {
      title: 'Shader glsl 实战 失败的钻石 II'
    }
  },
  {
    path: '/glsl/diamond-iii',
    name: 'DiamondIII',
    component: () => import('@/views/glsl/diamond-iii/index'),
    meta: {
      title: 'Shader glsl 实战 钻石 III'
    }
  },
  {
    path: '/glsl/phong-n-blinn-phong',
    name: 'PhongNBlinnPhong',
    component: () => import('@/views/glsl/phong-n-blinn-phong/index'),
    meta: {
      title: 'Shader glsl 实战 Phong 与 Blinn-Phong 光照模型实现'
    }
  },
  {
    path: '/glsl/ykob/ground',
    name: 'WaveGround',
    component: () => import('@/views/glsl/ykob/ground/index'),
    meta: {
      title: 'sketch-threejs 中的波浪网格'
    }
  },
  {
    path: '/glsl/ykob/ground-title',
    name: 'GroundTitle',
    component: () => import('@/views/glsl/ykob/ground-title/index'),
    meta: {
      title: 'sketch-threejs 中的波浪网格 + Title'
    }
  },
  {
    path: '/glsl/ykob/ground-title-sky-octahedron',
    name: 'SkyOctahedron',
    component: () => import('@/views/glsl/ykob/ground-title-sky-octahedron/index'),
    meta: {
      title: 'sketch-threejs 顶部变异球'
    }
  },
  {
    path: '/glsl/ykob/ground-title-sky-octahedron-shell',
    name: 'SkyOctahedronShell',
    component: () => import('@/views/glsl/ykob/ground-title-sky-octahedron-shell/index'),
    meta: {
      title: 'sketch-threejs Home 全效果'
    }
  },
  {
    path: '/glsl/ykob/fireball',
    name: 'Fireball',
    component: () => import('@/views/glsl/ykob/fireball/index'),
    meta: {
      title: 'sketch-threejs Fireball 火球效果'
    }
  },
  {
    path: '/glsl/ykob/fireball2',
    name: 'Fireball2',
    component: () => import('@/views/glsl/ykob/fireball2/index'),
    meta: {
      title: 'sketch-threejs Fireball2 火球效果 II'
    }
  },
  // {
  //   path: '/glsl/pbr',
  //   name: 'Pbr',
  //   component: () => import('@/views/glsl/pbr/index'),
  //   meta: {
  //     title: 'Shader glsl 实战 PBR 基于物理渲染（带贴图）'
  //   }
  // }
]
export default glsl
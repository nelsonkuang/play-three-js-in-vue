const normal = [
  {
    path: '/normal/emerald',
    name: 'Emerald',
    component: () => import('@/views/normal/emerald/index'),
    meta: {
      title: 'Three.js 官方实例魔改 宝石（使用环境贴图反光）'
    }
  },
  {
    path: '/normal/animation-basic',
    name: 'AnimationBasic',
    component: () => import('@/views/normal/animation-basic/index'),
    meta: {
      title: 'Three.js 官方基础动画例子修改'
    }
  },
]
export default normal
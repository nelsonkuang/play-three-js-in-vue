import Vue from 'vue'
import VueRouter from 'vue-router'
import glsl from './glsl'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('@/views/index'),
    meta: {
      title: '主页'
    }
  },
  ...glsl
]

const router = new VueRouter({
  routes
})

export default router

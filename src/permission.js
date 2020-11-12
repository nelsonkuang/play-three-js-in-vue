import router from './router'
import NProgress from 'nprogress' // Progress 进度条
import 'nprogress/nprogress.css' // Progress 进度条样式

NProgress.inc(0.2)
NProgress.configure({
  easing: 'ease',
  speed: 500,
  showSpinner: false
})

router.beforeEach((to, from, next) => {
  NProgress.start()
  if (to.meta && to.meta.title) {
    document.title = to.meta.title
  }
  next()
})

router.afterEach(() => {
  NProgress.done() // 结束Progress
})

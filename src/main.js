import '@babel/polyfill'
import Vue from 'vue'
import App from './App'
import router from './router'

Vue.config.productionTip = false

import '@/permission' // permission control

Vue.config.productionTip = true // vue chrome 插件

new Vue({
  router,
  render: h => h(App)
}).$mount('#app')

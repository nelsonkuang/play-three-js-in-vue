<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <ul>
      <li v-for="route in routes" :key="route.path"><a href="javascript:void(0);" @click="$router.push(route.path)" rel="noopener">{{ route.meta.title }}</a></li>
    </ul>
    <h3>不断更新中...目标是 3D 编辑器</h3>
  </div>
</template>

<script>
/* eslint-disable no-alert, no-console */
export default {
  name: 'HelloWorld',
  data () {
    return {
      msg: '玩转 Three.js & GLSL'
    }
  },
  computed: {
    routes () {
      const arr = [...this.$router.options.routes]
      arr.shift()
      return arr
    },
  },
  created () {
    // console.log(this.routes)
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
.hello {
  padding-bottom: 100px;
}
</style>

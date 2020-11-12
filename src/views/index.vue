<template>
  <div class="home">
    <h1>{{ msg }}</h1>
    <ul>
      <li v-for="route in routes" :key="route.path"><a href="javascript:void(0);" @click="$router.push(route.path)" rel="noopener">{{ route.meta.title }}</a></li>
    </ul>
    <h3>不断更新中...</h3>
  </div>
</template>

<script>
/* eslint-disable no-alert, no-console */
export default {
  name: 'Home',
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
.home {
  padding-bottom: 100px;
}
</style>

<template>
  <div id="app">
    <Chart :points="this.stocks"></Chart>
  </div>
</template>

<script>
import Chart from './components/Chart.vue'

export default {
  name: 'App',
  components: {
    Chart
  },
  data() {
    return {
      "stocks": [
        {
          price: 501,
          amount: 30,
          sell: true
        },
        {
          price: 500,
          amount: 300,
          sell: true
        }
        , {
          price: 498,
          amount: 35,
          sell: false
        }
        , {
          price: 490,
          amount: 90,
          sell: false
        }
      ]
    }
  }


}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>

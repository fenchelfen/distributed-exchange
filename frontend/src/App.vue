<template>
  <div id="app">
    <h5>My address: {{eth.userAddress}}</h5>
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
  mounted() {
    // The provider
    const provider = this.$ethereum;

// Connect the provider
    provider.connect();

// ethereum info
    const {
      providerConnected,
      providerName,
      chainId,
      chainName,
      userAddress,
    } = this.ethereumInfo;
    console.log(providerConnected,
        providerName,
        chainId,
        chainName,
        userAddress,)
    this.$data.eth = {
      providerConnected: providerConnected,
      providerName: providerName,
      chainId: chainId,
      chainName: chainName,
      userAddress: userAddress
    }
  },
  data: function () {

    return {
      eth: {
        providerConnected: false,
      providerName: '',
      chainId: '',
      chainName: '',
      userAddress: ''
      },
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

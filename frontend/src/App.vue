<template>
  <div id="app">
    <h5>My address: {{ eth.userAddress }}</h5>
    <h5>My ETH balance in InnoDEX: {{ eth.innoDexETHBalance }}</h5>
    <h5>My SWOT balance in InnoDEX: {{ eth.innoDexSWOTBalance }}</h5>
    <div>
      <label for="eth">amount of ETH to put</label>
      <input id="eth" name="eth" v-model="buy_eth.amount">
      <button v-on:click="putETHOnInnoDex">put ETH on InnoDEX</button>
    </div>
    <div>
      <label for="swot">amount of SWOT to but</label>
      <input id="swot" name="swot" v-model="buy_swot.amount">
      <button v-on:click="buySWOTOnInnoDex">get SWOT on InnoDEX</button>
    </div>
    <div>
      <button v-on:click="updateInnoDexBalance">update balances</button>

    </div>

    <Chart :points="this.stocks"></Chart>
  </div>
</template>

<script>
/* eslint-disable */
import Chart from './components/Chart.vue'
import {dexAbi} from "./dex-abi";
import {ethers} from "ethers";

export default {
  name: 'App',
  components: {
    Chart
  },
  mounted() {

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
    this.$data.eth.userAddress = userAddress

    this.getOwner();


    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    console.log(signer);

    // contract connect
    const address = '0x18b06f4f00197ccc872d909801f28d17493ed889';
    const dexContract = new ethers.Contract(address, dexAbi, provider);
    const dexContractWithSigner = dexContract.connect(signer);
    console.log(dexContractWithSigner);
    this.eth.dexContractWithSigner = dexContractWithSigner;

    this.updateInnoDexBalance();


    // var contract = new Contract(dexAbi, address);
    // console.log(contract);
    // let res = contract.methods.depositEther().call();
    // console.log("res", res);
  },
  data: function () {

    return {
      buy_eth:{
        amount: 0
      },
      buy_swot:{
        amount: 0
      },
      eth: {
        innoDexETHBalance: 0,
        innoDexSWOTBalance: 0,
        providerConnected: false,
        providerName: '',
        chainId: '',
        chainName: '',
        userAddress: '',
        dexContractWithSigner: null,
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
  },
  methods: {
    getOwner() {
      ethereum.request({method: 'eth_accounts'}).then((data) => {
        console.log(data);
      }).catch()
    },
    updateInnoDexBalance() {
      console.log("started balance update");
      this.$data.eth.dexContractWithSigner.getETHBalance().then((balance) => {
        this.eth.innoDexETHBalance = ethers.utils.formatEther(balance)
      })

      this.$data.eth.dexContractWithSigner.getSWOTBalance().then((balance) => {
        this.eth.innoDexSWOTBalance = ethers.utils.formatEther(balance)
      })
      console.log("finished balance update");

    },
    putETHOnInnoDex() {
      let overrides = {
        // To convert Ether to Wei:
        value: ethers.utils.parseEther(this.buy_eth.amount.toString())     // ether in this case MUST be a string
      };
      console.log(this.buy_eth.amount)

      console.log(this.$data.eth.dexContractWithSigner.depositEther(overrides).then((el) => {
        console.log("then", el)
      }));
    },
    buySWOTOnInnoDex(){

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

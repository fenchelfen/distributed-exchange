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
      <label for="swot">limit order for SWOT in ETH</label>
      <input id="swot" name="swot" v-model="buy_swot.amount">
      <button v-on:click="buySWOTOnInnoDex">get SWOT</button>
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
import {swotAbi} from "./swot-abi";

const ETH = 1;
const SWOT = 0;


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

    // this.getOwner();


    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    console.log(signer);

    // contract connect
    const dexAddress = '0x3c808952cC1c944E28C612dC1301788cf7026572';
    const dexContract = new ethers.Contract(dexAddress, dexAbi, provider);
    const dexContractWithSigner = dexContract.connect(signer);
    console.log(dexContractWithSigner);
    this.eth.dexContractWithSigner = dexContractWithSigner;

    const swotAddress = '0xf0f78Bbfeb0fa35682a00f36FbE90c1331DA049c';
    const swotContract = new ethers.Contract(swotAddress, swotAbi, provider);
    const swotContractWithSigner = swotContract.connect(signer);
    console.log(swotContractWithSigner);
    this.eth.swotContractWithSigner = swotContractWithSigner;

    this.updateInnoDexBalance();

  },
  data: function () {

    return {
      buy_eth: {
        amount: 0
      },
      buy_swot: {
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
        swotContractWithSigner: null
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
    buySWOTOnInnoDex() {

      this.$data.eth.dexContractWithSigner.placeAskOrder(this.buy_swot.amount, ETH).then((res) => {
        console.log("buy", res)
      })
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

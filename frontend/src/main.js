/* eslint-disable */
import Vue from 'vue'
import App from './App.vue'
import web3Providers from 'vue-plugin-web3-providers';

Vue.config.productionTip = false

Vue.use(web3Providers);


new Vue({
  render: h => h(App),
}).$mount('#app')

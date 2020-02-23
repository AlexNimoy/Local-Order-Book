import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    orders: {
      lastUpdateId: '',
      bids: [],
      asks: []
    }
  },
  mutations: {
    loadOrders (state, orders) {
      state.orders = orders
    }
  },
  actions: {
    loadOrdersAsync ({ commit }) {
      window.setInterval(() => {
        fetch(process.env.VUE_APP_DEPTH_API)
          .then(response => response.json())
          .then(orders => { commit('loadOrders', orders) })
      }, 1000)
    }
  }
})

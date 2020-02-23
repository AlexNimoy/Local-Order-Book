<template>
  <div class="order_book">
    <h1>Local Order Book</h1>
    <div class="order_book__last_update">
      LastUpdateId: {{ orders.lastUpdateId }}
    </div>
    <div class="order_book__wrapper">
      <Section name="Buy Order" :orders="orders.bids" />
      <Section name="Sell Order" :orders="orders.asks" />
    </div>
  </div>
</template>

<script>
import Section from './Section'

export default {
  name: 'OrderBook',
  components: {
    Section
  },
  computed: {
    orders () {
      return this.$store.state.orders
    }
  },
  created () {
    this.$store.dispatch('loadOrdersAsync')
  }
}
</script>

<style lang="scss">
.order_book {
  &__wrapper {
    display: flex;
    justify-content: space-between;
    max-width: 50%;
  }
  &__section {
    padding: 10px;
    flex: 0 1 45%;
    border: 1px solid silver;
  }
  &__row {
    max-width: 350px;
    display: table-row;
    > div {
      display: table-cell;
      padding: 5px;
    }
  }
  &__header {
    font-weight: bold;
  }
}
</style>

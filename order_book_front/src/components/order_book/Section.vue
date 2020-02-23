<template>
  <div class="order_book__section">
    <h2>{{ name }}</h2>
    <div class="order_book__row">
      <div class="order_book__header">Price</div>
      <div class="order_book__header">Amount</div>
    </div>
    <div
      class="order_book__row lot"
      v-for="order in orders"
      :key="order[0]"
    >
      <div class="lot__price">{{ order[0] | price }}</div>
      <div class="lot__amount">{{ order[1] }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Section',
  props: {
    orders: {
      type: Array,
      required: true
    },
    name: {
      type: String,
      required: true
    }
  },
  filters: {
    price: function (value) {
      return value.toFixed(2)
    }
  }
}
</script>

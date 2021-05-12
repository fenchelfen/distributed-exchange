<template>
  <div id="root">
    <h5>Orders</h5>
    <div>
      <vue-bar-graph
          id="buy"
          :points="this.data_1"

          :width="400"
          :height="200"
          :show-values="true"
          :show-x-axis="true"
      />
      <vue-bar-graph
          id="sell"
          :points="this.data_2"
          :width="400"
          :height="200"
          :show-values="true"
          :show-x-axis="true"
      />
    </div>
  </div>

</template>

<script>
import VueBarGraph from 'vue-bar-graph';

export default {
  name: 'Chart',
  components: {
    VueBarGraph,
  },
  props: {
    points: {
      type: Array
    }
  },
  data() {
    let points = this.points;
    // console.log(points)
    let data_1 = [];
    let data_2 = [];
    for (const key in points) {
      const el = points[key]
      // console.log(el)
      if (el.sell) {
        data_1.push({label: el.price, value: el.amount})
      } else {
        data_2.push({label: el.price, value: el.amount})
      }
    }

    console.log(data_1);
    console.log(data_2);

    return {
      data_1: data_1.sort((a, b) => a.price > b.price ? 1 : -1),
      data_2: data_2.sort((a, b) => a.price > b.price ? 1 : -1),
    }
  },
  created: () => {
    // console.log("kek")
    setTimeout(() => {
      let buy = document.getElementById("buy");
      let sell = document.getElementById("sell");
      let rects = Array.from(buy.getElementsByTagName("rect"));
      rects.forEach((rect) => {
        rect.style.fill = "green";
      });

      let sell_rects = Array.from(sell.getElementsByTagName("rect"));
      sell_rects.forEach((rect) => {
        rect.style.fill = "red";
      });
    }, 10)

  }
}
</script>

<style scoped>
#root {
  width: 100%;
  height: 100%;
}
</style>

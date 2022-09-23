<template>
  <p>Provider</p>
</template>

<script lang="ts">
  import { defineComponent } from "vue";
  import { useRoute } from "vue-router";
  export default defineComponent({
    setup() {
      const route = useRoute();
      const network = typeof route.query.network == "string" ? route.query.network : "rinkeby";
      console.log("*** network", network);
    },
  });
  </script>
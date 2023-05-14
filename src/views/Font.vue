<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <h2>nota sans</h2>
    <Font :network="network" :address="address1" />
    <h2>londrina solid</h2>

    <Font :network="network" :address="address2" />
  </div>
</template>

<script lang="ts">
// view
import { defineComponent, ref } from "vue";
import { addresses } from "@/utils/addresses";

import Font from "@/components/Font.vue";

export default defineComponent({
  components: {
    Font,
  },
  setup() {
    const network = "mainnet";
    const address1 = addresses.noto_sans.mainnet;
    const address2 = addresses.londrina_solid.mainnet;
    console.log("*** chainId", network, address1);

    return {
      network,
      address1,
      address2,
    };
  },
});
</script>

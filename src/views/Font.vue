<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <Font :network="network" :address="address1" />
    <Font :network="network" :address="address2" />
  </div>
</template>

<script lang="ts">
// view
import { defineComponent, ref } from "vue";
import { addresses } from "@/utils/addresses/londrina_solid_mainnet";
import { Addresses } from "@/utils/addresses";

import Font from "@/components/Font.vue";

export default defineComponent({
  components: {
    Font,
  },
  setup() {
    const network = "mainnet";
    const address1 = "0xAeFA677f6C94B5db823fd837857D79B9d5AFba4e"// addresses.font;
    const address2 =  addresses.font;
    console.log("*** chainId", network, address1);
    
    return {
      network,
      address1,
      address2,
    };
    
  },
});
</script>

<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <p>Images from the on-chain asset provider.</p>
    <ProviderView assetProvider="dotNouns" :count="4" :offset="offset"
      debugMode="true" />
    <Mint
      :network="network"
      :tokenGated="true"
      :tokenAddress="tokenAddress"
      :tokenGateAddress="tokenGateAddress"
      :limit="1"
      :xrestricted="'On-Chain Splatter, Bitcoin Art or Alphabet'"
    />
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { useRoute } from "vue-router";
import Mint from "@/components/Mint.vue";
import ProviderView from "@/components/ProviderView.vue";
import { addresses } from "@/utils/addresses";

export default defineComponent({
  components: {
    ProviderView,
    Mint
  },
  setup() {
    const offset = ref<number>(0);
    const route = useRoute();
    const network =
      typeof route.query.network == "string" ? route.query.network : "goerli";
    const tokenAddress = addresses.dotNounsToken[network];
    const tokenGateAddress = addresses.dynamic[network];

    console.log("*** chainId", network, tokenAddress);
    return {
      network,
      tokenAddress,
      tokenGateAddress,
      offset
    };
  },
});
</script>

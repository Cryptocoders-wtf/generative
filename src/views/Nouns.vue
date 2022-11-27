<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <p>Images from the on-chain asset provider.</p>
    <div v-if="network != 'localhost'">
      <ProviderView assetProvider="nounsArt" />
      <ProviderView assetProvider="dotlilArt" />
      <ProviderView assetProvider="pnouns" />
      <ProviderView assetProvider="nouns" />
    </div>
    <ProviderView assetProvider="dotNouns" />
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { useRoute } from "vue-router";
import ProviderView from "@/components/ProviderView.vue";
import { addresses as localhost } from "@/utils/addresses/sample_localhost";
import { addresses as goerli } from "@/utils/addresses/sample_goerli";

const allAddresses: any = {
  localhost,
  goerli,
};

export default defineComponent({
  components: {
    ProviderView,
  },
  setup() {
    const route = useRoute();
    const network =
      typeof route.query.network == "string" ? route.query.network : "goerli";
    const addresses = allAddresses[network];
    const tokenAddress = addresses.sampleToken;
    console.log("*** chainId", network, tokenAddress);
    return {
      network,
      tokenAddress,
    };
  },
});
</script>

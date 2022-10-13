<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <ProviderView assetProvider="splatterArt" />
    <Mint
      v-if="network != 'localhost'"
      :network="network"
      :tokenGated="true"
      :tokenAddress="tokenAddress"
    />
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { useRoute } from "vue-router";
import { sampleColors } from "@/models/point";
import { generateSVGImage } from "@/generative/splatter";
import Mint from "@/components/Mint.vue";
import ProviderView from "@/components/ProviderView.vue";
import { addresses as mainnet } from "@/utils/addresses/splatter_mainnet";
import { addresses as localhost } from "@/utils/addresses/splatter_localhost";
import { addresses as goerli } from "@/utils/addresses/splatter_goerli";

const allAddresses: any = {
  mainnet,
  localhost,
  goerli,
};

export default defineComponent({
  components: {
    Mint,
    ProviderView,
  },
  setup() {
    const route = useRoute();
    const network =
      typeof route.query.network == "string" ? route.query.network : "goerli";
    const addresses = allAddresses[network];
    const tokenAddress = addresses.splatterToken;
    console.log("*** chainId", network, tokenAddress);
    return {
      network,
      tokenAddress,
    };
  },
});
</script>

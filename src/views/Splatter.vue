<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <p class="mb-2">
      Splatter is a fully on-chain generative art collection. Unlike most NFTs
      in the market, it dynamically generates images on the blockchain. Since it
      does not rely on either HTTP server or IPFT, it is fully decentralized and
      composable, and its availably is guaranteed by the blockchain itself.
    </p>
    <ProviderView assetProvider="splatterArt" />
    <Mint
      v-if="network != 'localhost'"
      :network="network"
      :tokenGated="true"
      :tokenAddress="tokenAddress"
      :tokenGateAddress="tokenGateAddress"
    />
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { useRoute } from "vue-router";
import Mint from "@/components/Mint.vue";
import ProviderView from "@/components/ProviderView.vue";
import { addresses } from "@/utils/addresses";

export default defineComponent({
  components: {
    Mint,
    ProviderView,
  },
  setup() {
    const route = useRoute();
    const network =
      typeof route.query.network == "string" ? route.query.network : "mainnet";
    const tokenAddress = addresses.splatterToken[network];
    const tokenGateAddress = addresses.tokenGate[network];
    console.log("*** chainId", network, tokenAddress);
    return {
      network,
      tokenAddress,
      tokenGateAddress,
    };
  },
});
</script>

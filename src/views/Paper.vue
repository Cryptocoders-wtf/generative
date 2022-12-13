<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <p class="mb-2">
      Paper Nouns are dynamically generated on the blockchain, taking advantage of
      the composability of Nouns.
    </p>
    <ProviderView
      v-if="true"
      assetProvider="paperNouns"
      network="mainnet"
      :offset="0"
      :count="4"
    />
    <Mint
      :network="network"
      :tokenGated="true"
      :tokenAddress="tokenAddress"
      :tokenGateAddress="tokenGateAddress"
      :limit="1"
      assetProvider="paperNouns"
      @minted="minted"
      :restricted="'Fully On-chain NFT collection series'"
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
    Mint,
  },
  setup() {
    const offset = ref<number>(0);
    const route = useRoute();
    const network =
      typeof route.query.network == "string" ? route.query.network : "goerli";
    const tokenAddress = addresses.paperNounsToken[network];
    const tokenGateAddress = addresses.dynamic[network];
    console.log("*** address2", tokenAddress, tokenGateAddress);

    const minted = async () => {
      console.log("***###*** minted event was fired");
    };

    console.log("*** chainId", network, tokenAddress);
    return {
      network,
      tokenAddress,
      tokenGateAddress,
      offset,
      minted,
    };
  },
});
</script>

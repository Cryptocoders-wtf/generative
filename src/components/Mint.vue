<template>
  <p>Mint</p>
  <NetworkGate :expectedNetwork="'0x4'">
    <p>Contents</p>
  </NetworkGate>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useStore } from "vuex";
import { useRoute } from "vue-router";
import { ethers } from "ethers";
import NetworkGate from "@/components/NetworkGate.vue";

const SplatterToken = {
  wabi: require("@/abis/SplatterToken.json"), // wrapped abi
};

export default defineComponent({
  props: [
    "addresses",
    "tokensPerAsset",
    "tokenAbi",
  ],
  components: {
    NetworkGate,
  },
  setup(props) {
    const route = useRoute();
    const store = useStore();

    const affiliateId =
      typeof route.query.ref == "string" ? parseInt(route.query.ref) || 0 : 0;

    const networkContext = computed(() => {
      if (
        store.state.account &&
        store.state.chainId == props.addresses.chainId
      ) {
        const provider = new ethers.providers.Web3Provider(
          store.state.ethereum
        );
        const signer = provider.getSigner();
        const contract = new ethers.Contract(
          props.addresses.tokenAddress,
          props.tokenAbi,
          signer
        );

        return { provider, signer, contract };
      }
      return null;
    });
  }
});
</script>

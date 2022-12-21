<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <p class="mb-2">
      Images from TypeScript prototype. {{ $t("message.touchToUpdate") }}
    </p>
    <div @click="updateImages">
      <img
        v-for="image in images"
        :key="image"
        :src="image"
        class="mr-1 mb-1 inline-block w-20"
      />
    </div>
    <p>Images from the on-chain asset provider.</p>
    <ProviderView assetProvider="sample" />
    <Mint :network="network" :tokenAddress="tokenAddress" />
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { useRoute } from "vue-router";
import { sampleColors } from "@/models/point";
import { generateSVGImage } from "@/generative/splatter";
import Mint from "@/components/Mint.vue";
import ProviderView from "@/components/ProviderView.vue";
import { addresses as localhost } from "@/utils/addresses/sample_localhost";
import { addresses as goerli } from "@/utils/addresses/sample_goerli";
import { Addresses } from "@/utils/addresses";

const allAddresses: Addresses = {
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
    const tokenAddress = addresses.sampleToken;
    console.log("*** chainId", network, tokenAddress);
    const images = ref<string[]>([]);
    const updateImages = () => {
      images.value = sampleColors.map((color) => generateSVGImage(color));
    };
    updateImages();
    return {
      images,
      updateImages,
      network,
      tokenAddress,
    };
  },
});
</script>

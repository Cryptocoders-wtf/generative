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
        class="mr-1 mb-1 inline-block w-32"
      />
    </div>
    <Mint :chainId="chainId" />
  </div>
</template>

<script lang="ts">
import { defineComponent, ref, Component } from "vue";
import { useRoute } from "vue-router";
import { sampleColors } from "@/models/point";
import { generateSVGImage } from "@/generative/splatter";
import Mint from "@/components/Mint.vue";
import { ChainIdMap } from "../utils/MetaMask";
import { addresses as mainnet } from "@/utils/addresses/splatter_mainnet";
import { addresses as localhost } from "@/utils/addresses/splatter_localhost";
import { addresses as rinkeby } from "@/utils/addresses/splatter_rinkeby";
import { addresses as goerli } from "@/utils/addresses/splatter_goerli";
const addresses = {
  mainnet, localhost, rinkeby, goerli
};

export default defineComponent({
  components: {
    Mint,
  },
  setup() {
    const route = useRoute();
    const network =
      typeof route.query.network == "string" ? route.query.network : "rinkeby";
    const chainId = ChainIdMap[network];
    console.log("*** chainId", chainId);
    const images = ref<string[]>([]);
    const updateImages = () => {
      images.value = sampleColors.map((color) => generateSVGImage(color));
    };
    updateImages();
    return {
      images,
      updateImages,
      chainId
    };
  },
});
</script>

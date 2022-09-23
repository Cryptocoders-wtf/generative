<template>
  <p>Images from on-chain asset provider</p>
  <div>
    <img
        v-for="image in images"
        :key="image"
        :src="image"
        class="mr-1 mb-1 inline-block w-32"
      />
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { useRoute } from "vue-router";
import { addresses } from "@/utils/addresses";
import { ethers } from "ethers";
import { svgImageFromSvgPart, sampleColors } from "@/models/point";

const IAssetProvider = {
  wabi: require("@/abis/IAssetProvider.json"), // wrapped abi
};

export default defineComponent({
  props: ["assetProvider"],
  setup(props) {
    const images = ref<string[]>([]);
    const route = useRoute();
    const network =
      typeof route.query.network == "string" ? route.query.network : "rinkeby";
    console.log("*** network", network);

    const providerAddress = addresses[props.assetProvider][network];
    console.log("*** address", providerAddress);
    const provider =
      network == "localhost"
        ? new ethers.providers.JsonRpcProvider()
        : new ethers.providers.AlchemyProvider(network);
    const assetProvider = new ethers.Contract(
      providerAddress,
      IAssetProvider.wabi.abi,
      provider
    );

    const fetchImages = async () => {
      const newImages = [];
      for (let i=0; i<sampleColors.length; i++) {
        const [svgPart, tag] = await assetProvider.functions.generateSVGPart(i);
        const image = svgImageFromSvgPart(svgPart, tag, sampleColors[i]);
        newImages.push(image);
      }
      images.value = newImages;
    };
    fetchImages();

    return {
      images
    }
  },
});
</script>

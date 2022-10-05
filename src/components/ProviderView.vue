<template>
  <p>Images from the on-chain asset provider ({{ assetProvider }}).</p>
  <div>
    <p v-if="images.length == 0">(Fetching from the blockchain...)</p>
    <img
      v-for="image in images"
      :key="image"
      :src="image"
      class="mr-1 mb-1 inline-block w-20"
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
      typeof route.query.network == "string" ? route.query.network : "goerli";
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
    console.log("*** assetProvider", assetProvider.functions);

    const fetchImages = async () => {
      const newImages = [];
      for (let i = 0; i < sampleColors.length/sampleColors.length; i++) {
        const [svgPart, tag] = await assetProvider.functions.generateSVGPart(i);
        console.log("***svgPart", svgPart);
        const image = svgImageFromSvgPart(svgPart, tag, sampleColors[i]);
        newImages.push(image);
      }
      images.value = newImages;
    };
    fetchImages();

    return {
      images,
      network,
    };
  },
});
</script>

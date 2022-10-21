<template>
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
const ISVGHelper = {
  wabi: require("@/abis/ISVGHelper.json"), // wrapped abi
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
    const svgHelperAddress = addresses["svgHelper"][network];
    console.log("*** address", providerAddress, svgHelperAddress);
    const provider =
      network == "localhost"
        ? new ethers.providers.JsonRpcProvider()
        : new ethers.providers.InfuraProvider(network);
    const assetProvider = new ethers.Contract(
      providerAddress,
      IAssetProvider.wabi.abi,
      provider
    );
    const svgHelper = new ethers.Contract(
      svgHelperAddress,
      ISVGHelper.wabi.abi,
      provider
    );
    console.log("*** assetProvider", assetProvider.functions);

    const fetchImages = async () => {
      const newImages = [];
      for (let i = 0; i < sampleColors.length; i++) {
        const [svgPart, tag, gas] = await svgHelper.functions.generateSVGPart(
          providerAddress,
          i
        );
        // console.log("svgPart", svgPart);
        const [traits] = await assetProvider.functions.generateTraits(i);
        console.log("gas", gas.toNumber(), traits);
        const image = svgImageFromSvgPart(svgPart, tag, sampleColors[i]);
        newImages.push(image);
        images.value = newImages.map((image) => image);
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

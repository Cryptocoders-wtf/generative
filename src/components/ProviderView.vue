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
  props: ["assetProvider", "debugMode", "network", "count", "offset"],
  setup(props) {
    const images = ref<string[]>([]);
    const route = useRoute();
    const network: string = (
      typeof route.query.network == "string"
        ? route.query.network
        : props.network || "goerli"
    ) as string;
    const alchemyKey = process.env.VUE_APP_ALCHEMY_API_KEY;
    // console.log("*** network", network, alchemyKey);

    const providerAddress = addresses[props.assetProvider][network];
    const svgHelperAddress = addresses["svgHelper"][network];
    // console.log("*** address", providerAddress, svgHelperAddress);
    const provider =
      network == "localhost"
        ? new ethers.providers.JsonRpcProvider()
        : network == "mumbai"
        ? new ethers.providers.JsonRpcProvider(
            "https://matic-mumbai.chainstacklabs.com"
          )
        : alchemyKey
        ? new ethers.providers.AlchemyProvider(network, alchemyKey)
        : new ethers.providers.InfuraProvider(network);

    console.log("*****", network, provider);

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
    // console.log("*** assetProvider", assetProvider.functions);

    const fetchImages = async () => {
      const newImages = [];
      for (let i = 0; i < (props.count || sampleColors.length); i++) {
        const [svgPart, tag, gas] = await svgHelper.functions.generateSVGPart(
          providerAddress,
          i + (props.offset || 0)
        );
        // console.log("svgPart", svgPart);
        const [traits] = await assetProvider.functions.generateTraits(
          i + (props.offset || 0)
        );
        if (props.debugMode) {
          console.log("gas", gas.toNumber(), traits);
        }
        const image = svgImageFromSvgPart(svgPart, tag, sampleColors[i]);
        newImages.push(image);
        images.value = newImages.map((image) => image);
      }
      images.value = newImages;
    };
    fetchImages();

    return {
      images,
    };
  },
});
</script>

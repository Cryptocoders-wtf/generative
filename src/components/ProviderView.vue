<template>
  <p>Provider</p>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { useRoute } from "vue-router";
import { addresses } from "@/utils/addresses";
import { ethers } from "ethers";

const IAssetProvider = {
  wabi: require("@/abis/IAssetProvider.json"), // wrapped abi
};

export default defineComponent({
  setup() {
    const route = useRoute();
    const network =
      typeof route.query.network == "string" ? route.query.network : "rinkeby";
    console.log("*** network", network);

    const providerAddress = addresses["splatter"][network];
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
      const [svgPart, tag] = await assetProvider.functions.generateSVGPart(10);
      console.log("**** fetch", svgPart, tag);
    };
    fetchImages();
  },
});
</script>

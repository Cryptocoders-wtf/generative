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
import { svgImageFromSvgPart, sampleColors } from "@/models/point";
import { getProvider, getSvgHelper, getAssetProvider } from "@/utils/const";

export default defineComponent({
  props: {
    assetProvider: {
      type: String,
      required: true,
    },
    debugMode: Boolean,
    network: String,
    count: Number,
    offset: Number,
  },
  setup(props) {
    const images = ref<string[]>([]);
    const route = useRoute();
    const network: string = (
      typeof route.query.network == "string"
        ? route.query.network
        : props.network || "goerli"
    ) as string;
    const alchemyKey = process.env.VUE_APP_ALCHEMY_API_KEY;
    const provider = getProvider(network, alchemyKey);
    console.log("*****", network, provider);

    const assetProvider = getAssetProvider(
      props.assetProvider,
      network,
      provider
    );
    const providerAddress = assetProvider.address;

    const svgHelper = getSvgHelper(network, provider);

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

<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <span v-for="(char, k) in strings" :key="k">
      <template v-if="ret[char]">
        <img :src="ret[char]" class="w-6 inline">
      </template>
    </span>
  </div>
</template>

<script lang="ts">
// view
import { defineComponent, ref } from "vue";
import { useRoute } from "vue-router";
import { sampleColors } from "@/models/point";
import { generateSVGImage } from "@/generative/splatter";
import { addresses } from "@/utils/addresses/londrina_solid_mainnet";
import { Addresses } from "@/utils/addresses";

import { getProvider, IFontProvider } from "@/utils/const";
import { ethers } from "ethers";
import {  decodeCompressData, path2SVG } from "@/utils/pathUtils";


export default defineComponent({
  setup() {
    const route = useRoute();
    const network = "mainnet";
    const tokenAddress = "0xAeFA677f6C94B5db823fd837857D79B9d5AFba4e"// addresses.font;
    // const tokenAddress =  addresses.font;
    console.log("*** chainId", network, tokenAddress);

    const alchemyKey = process.env.VUE_APP_ALCHEMY_API_KEY;
    const provider = getProvider(network, alchemyKey);
    const fontProvider = new ethers.Contract(
      tokenAddress,
      IFontProvider.wabi.abi,
      provider
    );

    const svg = ref("");
    // 48 ~ 126
    const strings = [ ];
    for(let i = 48; i < 127; i++) {
      strings.push(String.fromCharCode(i))
    }
    const ret = ref({});
    strings.map(async (char) => {
      const rawPathData = await fontProvider.functions.pathOf(char);
      const path = decodeCompressData(rawPathData[0].slice(2));
      const pathSVG = path2SVG(path);
      const encoded = Buffer.from(pathSVG).toString('base64');
      ret.value[char] = `data:image/svg+xml;base64,${encoded}`;
    });
    
    return {
      network,
      tokenAddress,
      svg,
      ret,
      strings,
    };
    
  },
});
</script>

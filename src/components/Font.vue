<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <span v-for="(char, k) in strings" :key="k">
      <template v-if="ret[char]">
        <img :src="ret[char]" class="inline w-6" />
      </template>
    </span>
  </div>
</template>

<script lang="ts">
// view
import { defineComponent, ref } from "vue";
import { addresses } from "@/utils/addresses/londrina_solid_mainnet";
import { Addresses } from "@/utils/addresses";

import { getProvider, IFontProvider } from "@/utils/const";
import { ethers } from "ethers";
import { decodeCompressData, path2SVG } from "@/utils/pathUtils";

export default defineComponent({
  props: {
    network: {
      type: String,
      required: true,
    },
    address: {
      type: String,
      required: true,
    },
  },
  setup(props) {
    console.log("*** chainId", props.network, props.address);

    const alchemyKey = process.env.VUE_APP_ALCHEMY_API_KEY;
    const provider = getProvider(props.network, alchemyKey);
    const fontProvider = new ethers.Contract(
      props.address,
      IFontProvider.wabi.abi,
      provider
    );

    // 48 ~ 126
    const strings = [];
    for (let i = 48; i < 127; i++) {
      strings.push(String.fromCharCode(i));
    }
    const ret = ref<{ [key: string]: string }>({});
    strings.map(async (char) => {
      const rawPathData = await fontProvider.functions.pathOf(char);
      const path = decodeCompressData(rawPathData[0].slice(2));
      const pathSVG = path2SVG(path);
      const encoded = Buffer.from(pathSVG).toString("base64");
      ret.value[char] = `data:image/svg+xml;base64,${encoded}`;
    });

    return {
      ret,
      strings,
    };
  },
});
</script>

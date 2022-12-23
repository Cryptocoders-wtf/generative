<template>
  <div class="m-8">
    <div v-for="(svg, k) in svgs" :key="k" class="flex">
      <img :src="svg.originalImageData" class="w-48 flex-item border-2 m-2"/>
      <img :src="svg.convedImageData" class="w-48 flex-item border-2 m-2" />
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";

import { svg2imgSrc } from "@/utils/svgtool";
import { convSVG2Path, dumpConvertSVG } from "@/utils/svgtool";

import semi from "../svgs/Semi-Cur_Eg.svg?raw";
import semi2 from "../svgs/Character_Long2_Semi.svg?raw";
import hanafuda from "../svgs/Hanafuda_April_Tanzaku_Alt.svg?raw";
import lix from "../svgs/Liuxingti.svg?raw";
import ss from "../svgs/SingularitySociety-LogoType-Color.svg?raw";
import svg from "../svgs/Sustainable_Development_Goals.svg?raw";

export default defineComponent({
  setup(props) {
    const svgs = [
      semi, semi2, hanafuda, lix, ss, svg
    ].map((svgText) => {
      const convedPath = convSVG2Path(svgText as string, true);
      const convedSVGText = dumpConvertSVG(convedPath);
      return {
        // data,
        originalImageData: svg2imgSrc(svgText as string),
        convedImageData: svg2imgSrc(convedSVGText as string),
      };
      // imgsrc: 
    })

    return {
      svgs,
    };
  }
});
</script>

<template>
  <div class="m-8">
    <div v-for="(svg, k) in svgs" :key="k" class="flex">
      <img :src="svg.originalImageData" class="flex-item m-2 w-48 border-2" />
      <img :src="svg.convedImageData" class="flex-item m-2 w-48 border-2" />
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

import f1F439 from "../svgs/emoji/1F439.svg?raw";
import f1F6FC from "../svgs/emoji/1F6FC.svg?raw";
import f1F94A from "../svgs/emoji/1F94A.svg?raw";
import f1F989 from "../svgs/emoji/1F989.svg?raw";
import f1F9A5 from "../svgs/emoji/1F9A5.svg?raw";
import f1FAE3 from "../svgs/emoji/1FAE3.svg?raw";
import BurkinaFaso from "../svgs/emoji/BurkinaFaso.svg?raw";
import E0C5 from "../svgs/emoji/E0C5.svg?raw";

import pnounsNFT_font_question from "../svgs/font/pnounsNFT_font_question.svg?raw";

export default defineComponent({
  setup(props) {
    const svgs = [
      f1F439,
      f1F6FC,
      f1F94A,
      f1F989,
      f1F9A5,
      f1FAE3,
      BurkinaFaso,
      E0C5,
      semi,
      semi2,
      hanafuda,
      lix,
      ss,
      svg,
      pnounsNFT_font_question,
    ].map((svgText) => {
      const convedPath = convSVG2Path(svgText as string, true);
      const convedSVGText = dumpConvertSVG(convedPath);
      return {
        // data,
        originalImageData: svg2imgSrc(svgText as string),
        convedImageData: svg2imgSrc(convedSVGText as string),
      };
      // imgsrc:
    });

    return {
      svgs,
    };
  },
});
</script>

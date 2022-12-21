<template>
  <div class="home">
    <div class="flex items-center justify-center space-x-8">
      <!-- Drag & Drop -->
      <div @dragover.prevent @drop.prevent class="mx-4 mt-4 h-24 w-48 border-4">
        <div @drop="dragFile">
          <input
            type="file"
            multiple
            @change="uploadFile"
            class="h-full w-full opacity-0"
          />
          put your svg
        </div>
      </div>
    </div>
    <div class="flex">
      <div class="flex-item" v-if="svgData">
        before<br />
        <img :src="svgData" class="mx-4 mt-4 h-48 w-48" />
      </div>
      <div class="flex-item" v-if="convedSVGData">
        after1<br />
        <img
          :src="convedSVGData"
          class="mx-4 mt-4 h-48 w-48"
          />
      </div>
      <div class="flex-item" v-if="convedSVGData2">
        after2<br />
        <img
          :src="convedSVGData2"
          class="mx-4 mt-4 h-48 w-48"
        />
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { convSVG2SVG, svg2imgSrc } from "@/utils/svgtool";
import format from "xml-formatter";

export default defineComponent({
  components: {},
  setup() {
    const file = ref();

    const svgData = ref("");
    const convedSVGData = ref("");
    const convedSVGData2 = ref("");

    const svgText = ref("");
    const convedSVGText = ref("");
    const convedSVGText2 = ref("");

    const readSVGData = async () => {
      svgText.value = await file.value.text();
      svgData.value = svg2imgSrc(svgText.value);
      convedSVGText.value = convSVG2SVG(svgText.value, true);
      convedSVGData.value = svg2imgSrc(convedSVGText.value);

      convedSVGText2.value = convSVG2SVG(svgText.value, true);
      convedSVGData2.value = svg2imgSrc(convedSVGText2.value);

    };

    const uploadFile = (e: any) => {
      if (e.target.files && e.target.files.length > 0) {
        file.value = e.target.files[0];
        readSVGData();
      }
    };
    const dragFile = (e: any) => {
      if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
        file.value = e.dataTransfer.files[0];
        readSVGData();
      }
    };
    return {
      uploadFile,
      dragFile,

      svgData,
      convedSVGData,

      svgText,
      convedSVGText,

      convedSVGText2,
      convedSVGData2,

      format,
    };
  },
});
</script>

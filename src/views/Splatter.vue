<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <p class="mb-2">{{ $t("message.touchToUpdate") }}</p>
    <div @click="updateImage">
      <img
        v-for="image in images"
        :key="image"
        :src="image"
        class="mr-1 mb-1 inline-block w-32"
      />
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { pathFromPoints, svgImageFromPath, randomize, sampleColors } from "@/models/point";
import { generatePoints } from "@/generative/splatter";

export default defineComponent({
  setup() {
    const images = ref<string[]>([]);

    const updateImage = () => {
      images.value = sampleColors.map((color) => {
        const points = generatePoints(
          randomize(30, 0.5),
          randomize(0.2, 0.5),
          randomize(0.3, 0.5)
        );
        const path = pathFromPoints(points);
        return svgImageFromPath(path, color);
      });
    };
    updateImage();
    return {
      images,
      updateImage,
    };
  },
});
</script>

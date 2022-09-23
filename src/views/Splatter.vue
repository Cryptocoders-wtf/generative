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
import { pathFromPoints, svgImageFromPath, randomize } from "@/models/point";
import { generatePoints } from "@/generative/splatter";

export default defineComponent({
  setup() {
    const images = ref<string[]>([]);

    const updateImage = () => {
      const color = [
        "#E26A6A",
        "#9C9C6A",
        "#6AE270",
        "#AEC7E3",
        "#6A7070",
        "#E2706A",
        "#A7B8EB",
        "#6A89E2",
        "#6B56EB",
        "#FF6961",
        "#77B6EA",
        "#6E6EFD",
        "#69D2FF",
        "#D6B900",
        "#EFCP00",
        "#9EB500",
        "#625103",
        "#8B280D",
      ];
      images.value = color.map((color) => {
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

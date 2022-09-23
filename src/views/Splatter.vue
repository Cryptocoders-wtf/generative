<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <p class="mb-2">{{ $t("message.touchToUpdate") }}</p>
    <div @click="updateImages">
      <img
        v-for="image in images"
        :key="image"
        :src="image"
        class="mr-1 mb-1 inline-block w-32"
      />
    </div>
    <ProviderView />
  </div>
</template>

<script lang="ts">
import { defineComponent, ref, Component } from "vue";
import { sampleColors } from "@/models/point";
import { generateSVGImage } from "@/generative/splatter";
import ProviderView from "@/components/ProviderView.vue";

export default defineComponent({
  components: {
    ProviderView
  },
  setup() {
    const images = ref<string[]>([]);
    const updateImages = () => {
      images.value = sampleColors.map((color) => generateSVGImage(color));
    };
    updateImages();
    return {
      images,
      updateImages,
    };
  },
});
</script>

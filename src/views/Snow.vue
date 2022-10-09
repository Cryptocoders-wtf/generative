<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <p class="mb-2">
      Images from TypeScript prototype. {{ $t("message.touchToUpdate") }}
    </p>
    <div @click="updateImages">
      <img
        v-for="image in images"
        :key="image"
        :src="image"
        class="mr-1 mb-1 inline-block w-20"
      />
    </div>
    <ProviderView assetProvider="snow" />
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { sampleColors } from "@/models/point";
import { generateSVGImage } from "@/generative/snow";
import ProviderView from "@/components/ProviderView.vue";

export default defineComponent({
  components: {
    ProviderView,
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

<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <p>Images from the on-chain asset provider.</p>
    <ProviderView assetProvider="reddit" />
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import ProviderView from "@/components/ProviderView.vue";

export default defineComponent({
  components: {
    ProviderView,
  },
  setup() {
    return {};
  },
});
</script>

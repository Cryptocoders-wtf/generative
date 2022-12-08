<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <ProviderView assetProvider="star" debugMode="true" />
    <ProviderView assetProvider="nounsV2" debugMode="true" network="mainnet" />
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

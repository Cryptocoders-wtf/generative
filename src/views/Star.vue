<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <ProviderView assetProvider="star" debugMode="true" />
    <ProviderView assetProvider="pnouns" debugMode="true" />
    <ProviderView assetProvider="paperNouns" debugMode="true" network="mainnet" :offset="500" />
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

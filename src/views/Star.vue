<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <ProviderView assetProvider="star" :debugMode="true" />
    <ProviderView
      assetProvider="pnouns"
      :debugMode="true"
      network="mainnet"
      :offset="1000"
    />
    <ProviderView
      assetProvider="paperNouns"
      :debugMode="true"
      network="mainnet"
      :offset="500"
    />
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
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

<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <ProviderView assetProvider="circles" :debugMode="true" />
    <ProviderView assetProvider="circleStencil" />
    <ProviderView assetProvider="stencil" />
    <ProviderView assetProvider="glassesStencil" />
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

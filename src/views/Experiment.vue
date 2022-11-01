<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <ProviderView assetProvider="circles" />
    <ProviderView assetProvider="circleStencil" />
    <ProviderView assetProvider="stencil" :debugMode="true"/>
    <ProviderView assetProvider="glassesStencil" />
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
    return {
    };
  },
});
</script>

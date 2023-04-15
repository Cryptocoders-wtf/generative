<template>
  <header
    id="header"
    class="mx-auto flex max-w-3xl items-center justify-between py-1.5"
  >
    <div class="flex items-center justify-start">
      <router-link :to="localizedUrl('/')">
        <img
          src="@/assets/logo.svg"
          width="250"
          class="h-auto"
          title="Open Galaxy"
        />
      </router-link>
    </div>
    <!--
    <nav id="nav" class="flex flex-wrap items-center justify-start">
      <router-link :to="localizedUrl('/')" class="text-md">{{
        $t("header.home")
      }}</router-link>
    </nav>
    -->

    <div id="networkgate">
      <NetworkGate :expectedNetwork="chainId" />
    </div>

    <div class="invisible">
      <Languages />
    </div>
  </header>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import Languages from "@/components/Languages.vue";
import NetworkGate from "@/components/NetworkGate.vue";
import { ChainIdMap } from "@/utils/MetaMask";

export default defineComponent({
  components: {
    Languages,
    NetworkGate,
  },

  setup(props) {
    const network = "mumbai";
    const chainId = ChainIdMap[network];

    return {
      chainId,
    };
  },
});
</script>

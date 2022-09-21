<template>
  <header
    id="header"
    class="mx-auto flex max-w-xl items-center justify-between py-1.5"
  >
    <div class="flex items-center justify-start gap-1">
      <img src="@/assets/AssetStoreLogo.png" width="40" height="auto" />
      <div class="text-left font-bold leading-none">
        <div>On-chain<br />Asset Store</div>
      </div>
    </div>
    <nav id="nav" class="flex flex-wrap items-center justify-start">
      <router-link :to="localizedUrl('/')" class="text-md">{{
        $t("header.home")
      }}</router-link>
    </nav>
    <Languages />
  </header>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import Languages from "@/components/Languages.vue";

export default defineComponent({
  components: {
    Languages,
  },
});
</script>

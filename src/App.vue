<template>
  <Suspense>
    <router-view />
  </Suspense>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { useI18nParam } from "@/i18n/utils";
import { initializeEthereum } from "./utils/MetaMask";

export default defineComponent({
  setup() {
    initializeEthereum();
    useI18nParam();
    return {};
  },
});
</script>

<style>
#app {
  /* font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50; */
  @apply text-center font-sans text-gray-700 antialiased;
}

#header {
  box-shadow: 0 1px 0px 0 rgb(0 0 0 / 10%), 0 2px 0px 0px rgb(0 0 0 / 10%);
}

#header #nav {
  /* padding: 30px; */
  /* @apply p-8; */
}

#header #nav a {
  /* font-weight: bold;
  color: #2c3e50; */
  @apply font-bold text-gray-700;
  @apply relative;
}

#header #nav a.router-link-exact-active {
  /* color: #42b983; */
  @apply text-green-600;
}

#header #nav a::after {
  content: "|";
  @apply mr-1;
  @apply ml-1;
  @apply inline-block;
  @apply relative;
  @apply bottom-0.5;
}

#header #nav a:last-child::after {
  @apply content-none;
}

a {
  @apply cursor-pointer;
}
</style>

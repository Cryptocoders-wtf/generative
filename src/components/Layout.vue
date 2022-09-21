<template>
  <div class="layout">
    <Header />
    <router-view />
  </div>
</template>

<script lang="ts">
import { defineComponent, onMounted, onUnmounted } from "vue";
import Header from "@/components/Header.vue";
import { useStore } from "vuex";

export default defineComponent({
  name: "AppLayout",
  components: {
    Header,
  },
  setup() {
    const store = useStore();
    const setWindowWidth = () => {
      store.commit("setWindowWidth", window.innerWidth);
    };
    store.commit("setWindowWidth", window.innerWidth);
    onMounted(() => {
      window.addEventListener("resize", setWindowWidth);
    });
    onUnmounted(() => {
      window.removeEventListener("resize", setWindowWidth);
    });
  },
});
</script>

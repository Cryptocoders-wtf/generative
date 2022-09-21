<template>
  <span class="font-londrina font-yusei">
    <select @change="updateValue">
      <option
        v-for="(option, index) in languages"
        :value="option"
        :key="index"
        :selected="option == selectedValue ? true : false"
      >
        {{ $t("languages." + option) }}
      </option>
    </select>
  </span>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useI18n } from "vue-i18n";

import { languages } from "@/i18n/index";

export default defineComponent({
  setup() {
    const route = useRoute();
    const router = useRouter();
    const i18n = useI18n();

    const selectedValue = ref(route.params.lang || i18n.locale.value);

    const updateValue = (value: { target: HTMLSelectElement }) => {
      const basePath = (() => {
        if (route.params.lang) {
          return route.path.slice(route.params.lang.length + 1);
        }
        return route.path;
      })();
      const newPath = `/${value.target.value}${basePath}${location.search}`;
      if (newPath !== route.path) {
        router.push(newPath);
      }
    };
    return {
      languages,
      selectedValue,
      updateValue,
    };
  },
});
</script>

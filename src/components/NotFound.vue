<template>
  <div class="mt-10 lg:flex">
    <div class="flex w-full flex-1 flex-col px-4 pb-4 lg:w-1/2">
      <div class="font-londrina mt-4 text-4xl">
        {{ $t("message.notFoundMessage") }}
      </div>
    </div>
  </div>
</template>
<script lang="ts">
import { defineComponent } from "vue";
export default defineComponent({});
</script>

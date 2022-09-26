<template>
  <span class="font-londrina font-yusei ml-16">
    <span v-if="hasMetaMask">
      <span v-if="account">
        <button
          type="button"
          v-if="isBusy"
          class="inline-block rounded px-6 py-2.5 leading-tight text-gray-500 shadow-md"
          disabled
        >
          <img
            class="absolute h-3 w-8 animate-spin"
            src="@/assets/red160px.png"
          />
          <span class="ml-10">{{ $t("message.processing") }}</span>
        </button>
        <button
          v-else
          @click="signIn"
          class="inline-block rounded bg-green-600 px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
        >
          {{ $t("menu.connected") }}
        </button>
      </span>
      <span v-else>
        <button
          type="button"
          v-if="isBusy"
          class="inline-block rounded px-6 py-2.5 leading-tight text-gray-500 shadow-md"
          disabled
        >
          <img
            class="absolute h-3 w-8 animate-spin"
            src="@/assets/red160px.png"
          />
          <span class="ml-10">{{ $t("message.processing") }}</span>
        </button>
        <button
          v-else
          @click="connect"
          class="inline-block rounded bg-green-500 px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
        >
          {{ $t("menu.connect") }}
        </button>
      </span>
    </span>
    <span v-else>
      <button
        disabled
        class="inline-block rounded bg-gray-400 px-6 py-2.5 leading-tight text-white shadow-md"
      >
        {{ $t("menu.nometamask") }}
      </button>
    </span>
  </span>
</template>

<script lang="ts">
import { defineComponent, computed, ref } from "vue";
import { useStore } from "vuex";
import { requestAccount } from "../utils/MetaMask";

export default defineComponent({
  setup() {
    const store = useStore();
    const account = computed(() => store.state.account);
    const isSignedIn = computed(() => store.getters.isSignedIn);
    const isBusy = ref(false);
    const connect = async () => {
      isBusy.value = true;
      try {
        await requestAccount(); // ethereum.on('accountsChanged') in App.vue will handle the result
      } catch (e) {
        console.log(e);
      }
      isBusy.value = false;
      console.log("*****", store.state.account);
      // signIn();
    };
    const hasMetaMask = computed(() => {
      return store.getters.hasMetaMask;
    });

    return {
      hasMetaMask,
      account,
      isSignedIn,
      isBusy,
      connect,
    };
  },
});
</script>

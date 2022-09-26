<template>
  <div>
    <div v-if="networkGate == 'invalidNetwork'">
      <p>{{ $t("mint.switchNetwork") }}</p>
      <button
        @click="switchToValidNetwork"
        class="mb-2 inline-block rounded bg-green-600 px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
      >
        {{ $t("mint.switchNetworkButton") }}
      </button>
    </div>
    <div v-else-if="networkGate == 'noAccount'">
      <p class="mb-2">
        {{ $t("mint.connectMetamask") }}
        <Connect />
      </p>
    </div>
    <div v-else>
      <slot />
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useStore } from "vuex";
import { switchNetwork } from "../utils/MetaMask";
import Connect from "@/components/Connect.vue";

export default defineComponent({
  props: ["expectedNetwork"],
  components: {
    Connect,
  },
  setup(props) {
    const store = useStore();
    const networkGate = computed(() => {
      if (!store.state.account) {
        return "noAccount";
      }
      if (store.state.chainId != props.expectedNetwork) {
        return "invalidNetwork";
      }
      return "valid";
    });
    const switchToValidNetwork = async () => {
      await switchNetwork(props.expectedNetwork);
    };
    return { networkGate, switchToValidNetwork };
  },
});
</script>

<template>
  <div class="border-1 m-10 rounded-md border border-gray-300 bg-white p-5">
    <div class="m-10">
      <h2 class="text-3xl font-bold">{{ token_obj.data.name }}</h2>
    </div>

    <div v-if="token_obj.data.name">
      <div v-if="token_obj.price > 0">
        <p class="text-left text-2xl font-bold text-orange-600">On Sale!</p>
        <p class="text-left font-sans text-3xl font-bold">
          {{ token_obj.price }} ETH
        </p>
      </div>
      <div v-else-if="token_obj.price < 0">
        <img
          src="@/assets/preload.gif"
          class="mx-auto h-10 w-10 align-middle"
        />
      </div>
      <div v-else>
        <p class="text-gray-2990 text-left text-2xl font-bold">Not on Sale.</p>
      </div>
    </div>

    <div v-if="token_obj.isOwner">
      <input
        v-model="set_price"
        type="text"
        id="price"
        class="my-5 block w-full rounded-lg border border-gray-300 p-2.5 text-sm text-gray-900 focus:border-blue-500 focus:ring-blue-500 dark:border-gray-600 dark:bg-gray-700 dark:text-white dark:placeholder-gray-400 dark:focus:border-blue-500 dark:focus:ring-blue-500"
        placeholder="Input Price (ETH)"
        :disabled="isExecuting == 1"
        :class="isExecuting == 1 ? 'bg-gray-500 bg-opacity-80' : 'bg-gray-100'"
        required
      />

      <div v-if="isExecuting == 0">
        <button
          @click="setPrice(token_obj.token_id)"
          class="my-5 mr-2 mb-2 rounded-lg bg-gradient-to-br from-purple-600 to-blue-500 px-10 py-5 text-center text-sm font-medium text-white hover:bg-gradient-to-bl focus:outline-none focus:ring-4 focus:ring-blue-300 dark:focus:ring-blue-800"
          :class="isChangePrice ? '': 'opacity-30'"
          :disabled="!isChangePrice"
          >
          Set price
        </button>
      </div>
      <div v-if="isExecuting == 1">
        <img
          class="mx-auto h-10 w-10 align-middle"
          src="@/assets/preload.gif"
        />
      </div>
    </div>
    <div v-else>
      <div v-if="token_obj.price > 0">
        <div v-if="isExecuting == 0">
          <button
            @click="purchase(token_obj.token_id)"
            class="my-5 mr-2 mb-2 rounded-lg bg-gradient-to-br from-purple-600 to-blue-500 px-10 py-5 text-center text-sm font-medium text-white hover:bg-gradient-to-bl focus:outline-none focus:ring-4 focus:ring-blue-300 dark:focus:ring-blue-800"
          >
            BUY!
          </button>
        </div>
        <div v-if="isExecuting == 1">
          <img
            class="mx-auto h-10 w-10 align-middle"
            src="@/assets/preload.gif"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref, computed, PropType, toRefs, watch } from "vue";
import { utils } from "ethers";
import { useStore } from "vuex";
import { Token721p2p } from "@/models/token";

export default defineComponent({
  props: {
    token_obj: {
      type: Object as PropType<Token721p2p>,
      required: true,
    },
  },
  emits: ["purchased", "priceUpdated"],
  setup(props, context) {
    const isExecuting = ref(0); // 0:non-execute, 1:executing, 2:complete
    const store = useStore();
    const set_price = ref<string>("0");
    const { token_obj } = toRefs(props);
    watch(token_obj, () => {
      console.log("TokenActions: detected token_obj change.");
      set_price.value = token_obj.value?.price;
    });
    const account = computed(() => store.state.account);

    const polling = async (tx: any) => {
      const receipt = await tx.wait();
      if (receipt.status == 1) {
        return;
      } else {
        console.log("receipt", receipt);
        alert("Sorry, transaction failed.");
      }
    };

    const setPrice = async (id: number) => {
      if (store.state.networkContext == null) {
        return;
      }
      isExecuting.value = 1; // execute

      try {
        console.log(id);
        const tokenid = id;
        console.log("set_price : ", set_price.value, "tokenid : ", tokenid);
        const price = utils.parseEther(set_price.value);
        console.log(tokenid, set_price);

        console.log("price : ", price);

        const { contract } = store.state.networkContext;
        const tx = await contract.setPriceOf(tokenid, price);
        const result = await tx.wait();
        await polling(tx);
        isExecuting.value = 0; // non-execute
        context.emit("priceUpdated");
      } catch (e) {
        console.error(e);
        alert("Sorry, setPrice failed with:" + e);
        isExecuting.value = 0; // non-execute
      }
    };
    const isChangePrice = computed(() => {
      return token_obj.value.price !== set_price.value
    });
    
    const purchase = async (id: number) => {
      if (store.state.networkContext == null) {
        return;
      }
      isExecuting.value = 1; // execute
      const { contract } = store.state.networkContext;
      try {
        //        console.log(id,(token_.value));
        const price = await contract.getPriceOf(id);
        const owner = await contract.ownerOf(id);
        const tx = await contract.purchase(id, account.value, owner, {
          value: price,
        });
        const result = await tx.wait();
        await polling(tx);
        isExecuting.value = 0; // non-execute
        context.emit("purchased");
      } catch (e) {
        console.error(e);
        isExecuting.value = 0; // non-execute
        alert("Sorry, purchase failed with:" + e);
        isExecuting.value = 0; // non-execute
      }
    };

    return {
      setPrice,
      purchase,
      set_price,
      isExecuting,
      isChangePrice,
    };
  },
});
</script>

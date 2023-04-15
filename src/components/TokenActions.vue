<template>
  <div class="rounded-md border-1 border m-10 p-5 border-gray-300 bg-white">
    <div class="m-10">
      <h2 class="font-bold text-3xl">{{ token_obj.data.name }}</h2>
    </div>

    <div v-if="token_obj.data.name">
      <div v-if="token_obj.price > 0">
            <p class="text-orange-600 font-bold  text-2xl text-left">Sale! </p>
            <p class=" font-bold font-sans text-3xl text-left">
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
            <p class="text-gray-2990 font-bold  text-2xl text-left">Not on Sale! </p>
          </div>
      </div>

    
    <div v-if="token_obj.isOwner">
      <input
            v-model="set_price"
            type="text"
            id="price"
            class="my-5 block w-full rounded-lg border border-gray-300 bg-gray-50 p-2.5 text-sm text-gray-900 focus:border-blue-500 focus:ring-blue-500 dark:border-gray-600 dark:bg-gray-700 dark:text-white dark:placeholder-gray-400 dark:focus:border-blue-500 dark:focus:ring-blue-500"
            placeholder="Input Price (ETH)"
            required
      />

      <button
        @click="setPrice(token_obj.token_id)"
        class="my-5 mr-2 mb-2 rounded-lg bg-gradient-to-br from-purple-600 to-blue-500 px-20 py-5 text-center text-sm font-medium text-white hover:bg-gradient-to-bl focus:outline-none focus:ring-4 focus:ring-blue-300 dark:focus:ring-blue-800"
      >
        Set price
      </button>

    </div>
    <div v-else>
      <div v-if="token_obj.price > 0">


      <button
        @click="purchase(token_obj.token_id)"
        class="my-5 mr-2 mb-2 rounded-lg bg-gradient-to-br from-purple-600 to-blue-500 px-20 py-5 text-center text-sm font-medium text-white hover:bg-gradient-to-bl focus:outline-none focus:ring-4 focus:ring-blue-300 dark:focus:ring-blue-800"
      >
         BUY!
      </button>
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
    },
  },
  setup(props) {
    const store = useStore();
    const set_price = ref<string>("0");
    const { token_obj } = toRefs(props);
    watch(token_obj, () => {
      set_price.value = token_obj.value?.price;
    });
    const account = computed(() => store.state.account);

    const setPrice = async (id: number) => {
      if (store.state.networkContext == null) {
        return;
      }

      try {
        console.log(id);
        const tokenid = id;
        console.log("set_price : ", set_price.value, "tokenid : ", tokenid);
        const price = utils.parseEther(set_price.value);
        console.log(tokenid, set_price);

        console.log("price : ", price);

        const { contract } = store.state.networkContext;
        await contract.setPriceOf(tokenid, price);
      } catch (e) {
        console.error(e);
        alert("Sorry, setPrice failed with:" + e);
      }
    };
    const purchase = async (id: number) => {
      if (store.state.networkContext == null) {
        return;
      }
      const { contract } = store.state.networkContext;
      try {
        //        console.log(id,(token_.value));
        const price = await contract.getPriceOf(id);
        const owner = await contract.ownerOf(id);
        await contract.purchase(id, account.value, owner, { value: price });
      } catch (e) {
        console.error(e);
        alert("Sorry, purchase failed with:" + e);
      }
    };

    return {
      setPrice,
      purchase,
      set_price,
    };
  },
});
</script>

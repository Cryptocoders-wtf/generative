<template>
  <div>
    <div v-if="token_obj.price > 0">On Sale! {{ token_obj.price }} eth</div>
    <div v-else>Not on sale.</div>

    <div v-if="token_obj.isOwner">
      <input
        type="text"
        v-model="set_price"
        maxlength="512"
        minlength="1"
        class="border-1 my-2 rounded-sm bg-gray-100 text-sm text-sm text-slate-500 file:text-gray-800 hover:bg-white"
      />

      <button
        @click="setPrice(token_obj.token_id)"
        class="mb-2 inline-block rounded bg-green-600 px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
      >
        Set price
      </button>
    </div>
    <div v-else>
      <div v-if="token_obj.price > 0">
        <button
          @click="purchase(token_obj.token_id)"
          class="mb-2 inline-block rounded bg-green-600 px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
        >
          Purchase!
        </button>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref, computed } from "vue";
import { BigNumber, utils } from "ethers";
import { useStore } from "vuex";

export default defineComponent({
  props: {
    token_obj: {
      type: Object,
    },
  },
  emits: ["purchased"],

  setup(props, context) {
    const store = useStore();
    const set_price = ref<number>(0);
    const account = computed(() => store.state.account);

    const setPrice = async (id: number) => {
      if (store.state.networkContext == null) {
        return;
      }

      try {
        console.log(id);
        const tokenid = id;
        console.log("set_price : ", set_price.value, "tokenid : ", tokenid);
        const price = BigNumber.from(set_price.value);
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
        context.emit("purchased");
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

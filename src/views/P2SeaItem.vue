<template>
  <div class="home">
    <div class="flex justify-center">
      <div class="mt-2">
        <div v-if="executeMode == 0">
          <img class="h-20 w-20" src="@/assets/preload.gif" />
        </div>
        <div class="mx-8" v-if="executeMode != 0">
          {{ token_obj.data.name }}
          <img :src="token_obj.data.image" class="w-72 border-2" />
          {{ token_obj.price }} eth
        </div>
      </div>
    </div>

    <TokenActions :token_obj="token_obj" @purchased="purchased" />
  </div>

  <NetworkGate :expectedNetwork="chainId" />
</template>

<script lang="ts">
import { defineComponent, ref, computed } from "vue";
import { svg2imgSrc } from "@/utils/svgtool";
import { BigNumber, utils } from "ethers";

// mint
import NetworkGate from "@/components/NetworkGate.vue";
import { ChainIdMap, displayAddress } from "@/utils/MetaMask";
import {
  useSVGTokenNetworkContext,
  getProvider,
  getSVGTokenContract,
} from "@/utils/const";

import { addresses } from "@/utils/addresses";
import TokenActions from "@/components/TokenActions.vue";

//
import { parse } from "svg-parser";
import { convSVG2Path, dumpConvertSVG } from "@/utils/svgtool";
import { compressPath } from "@/utils/pathUtils";

import { useRoute } from "vue-router";
import { useStore } from "vuex";

const sleep = async (seconds: number) => {
  return await new Promise((resolve) => setTimeout(resolve, seconds * 1000));
};

export default defineComponent({
  components: {
    NetworkGate,
    TokenActions,
  },
  setup(props) {
    const pathData = ref<any>([]);
    const existData = computed(() => {
      return pathData.value.length > 0;
    });

    interface item {
      data: {
        name: string;
        image: string;
      };
      price: any;
      isOwner: boolean;
      token_id: number;
    }

    const token_obj = ref<item>({
      data: { name: "", image: "" },
      price: 0,
      isOwner: false,
      token_id: 0,
    });

    const reset = () => {
      pathData.value = [];
    };

    const store = useStore();
    const route = useRoute();
    const account = computed(() => store.state.account);

    // store      contract="0x610178dA211FEF7D417bC0e6FeD39F05609AD788"
    // provider      contract="0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e"
    // token      contract="0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0"
    // const network = "localhost";
    // const tokenAddress = "0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0";

    // store      contract="0x442622c789E5489A222141d06966608a2980E915"
    // provider      contract="0x24F08949190D291DaBb9d7a828ad048FE6250E0C"
    // token      contract="0x07f21753E1DA964fc7131571DD999471C6492e7E"

    // store      contract="0x05ce81EC1751E2317ddc2E90948EBc6Ca66781a1"
    // provider      contract="0xc65Ffa203d73538557Cff496bE85BD12B28927ca"
    // token      contract="0x5F0f949949c82f660B38FC7601A45498fa2C9fC9"

    const network = "mumbai";
    // const tokenAddress = "0x67b8571A13410a2687b8ceA1C416b88d75165Fc6";
    const tokenAddress = addresses.svgtoken[network];

    const chainId = ChainIdMap[network];

    const { networkContext } = useSVGTokenNetworkContext(chainId, tokenAddress);
    store.state.networkContext = networkContext;

    const alchemyKey = process.env.VUE_APP_ALCHEMY_API_KEY;
    const provider = getProvider(network, alchemyKey);
    const tokenContract = getSVGTokenContract(tokenAddress, provider);

    const executeMode = ref(0); // 0:loading, 1:executing, 2:non-execute

    const nextToken = ref(0);

    const updateToken = async () => {
      console.log("route.params.token_id", route.params.token_id);
      const token_id = route.params.token_id; //get from url parameter

      // console.log("load token:" + token + ' ' + token_id);

      const owner = await tokenContract.ownerOf(token_id);
      const ret = await tokenContract.tokenURI(token_id);
      console.log(ret);
      const data = JSON.parse(atob(ret.split(",")[1]));
      const price_big = await tokenContract.getPriceOf(token_id);
      // const price = price_big.toNumber();
      const price = price_big;

      console.log(price);

      const isOwner =
        utils.getAddress(account.value) == utils.getAddress(owner);

      token_obj.value = {
        data: data,
        price: price,
        isOwner: isOwner,
        token_id: parseInt(String(token_id)),
      };

      console.log(token_obj);
      executeMode.value = 2; // non-execute
    };
    updateToken();

    const purchased = async () => {
      console.log("***###*** purchased event was fired");
      updateToken();
    };

    const polling = async () => {
      let state = true;
      while (state) {
        await sleep(2);
        const nextId = await tokenContract.totalSupply();
        if (nextToken.value != nextId.toNumber()) {
          nextToken.value = nextId.toNumber();
          state = false;
        }
      }
    };

    return {
      chainId,
      token_obj,
      existData,
      executeMode,
      purchased,
    };
  },
});
</script>

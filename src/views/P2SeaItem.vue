<template>
  <div class="home">

    <div class="flex justify-center">
        <div class="mt-2">

        <div class="mx-8">
            {{ token_obj.data.name }}
            <img :src="token_obj.data.image" class="w-72 border-2" />
            {{ token_obj.price }} 
        </div>
        </div>
        <div>
        <a
            href="https://testnets.opensea.io/ja/collection/svgtokenv1-4?search[sortAscending]=false&search[sortBy]=CREATED_DATE"
            class="underline"
            target="_blank"
            >See NFTs on OpenSea</a
        >
        </div>
    </div>
    <NetworkGate :expectedNetwork="chainId">
        <div class="flex justify-center">
          <div
            @click="mint"
            :disabled="!existData"
            class="mb-2 inline-block cursor-pointer rounded px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
            :class="
              existData
                ? 'bg-green-600 focus:bg-green-700'
                : 'bg-green-600 bg-opacity-20 focus:bg-green-700'
            "
          >
            (buy)
          </div>
        </div>
    </NetworkGate>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref, computed } from "vue";
import { svg2imgSrc } from "@/utils/svgtool";

// mint
import NetworkGate from "@/components/NetworkGate.vue";
import { BigNumber } from "ethers";
import { ChainIdMap, displayAddress } from "@/utils/MetaMask";
import {
  useSVGTokenNetworkContext,
  getProvider,
  getSVGTokenContract,
} from "@/utils/const";

//
import { parse } from "svg-parser";
import { convSVG2Path, dumpConvertSVG } from "@/utils/svgtool";
import { compressPath } from "@/utils/pathUtils";

import { useRoute } from "vue-router";

const sleep = async (seconds: number) => {
  return await new Promise((resolve) => setTimeout(resolve, seconds * 1000));
};

export default defineComponent({
  components: {
    NetworkGate,
  },
  setup(props) {
    const pathData = ref<any>([]);
    const existData = computed(() => {
      return pathData.value.length > 0;
    });

    interface item {
        data: {
            name: string,
            image: string
        },
        price: string
    }

    const token_obj = ref<item>({data:{name:'', image:''}, price:''})

    const reset = () => {
      pathData.value = [];
    };

    const route = useRoute();


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
    const tokenAddress = "0x67b8571A13410a2687b8ceA1C416b88d75165Fc6";

    const chainId = ChainIdMap[network];

    const { networkContext } = useSVGTokenNetworkContext(chainId, tokenAddress);

    const alchemyKey = process.env.VUE_APP_ALCHEMY_API_KEY;
    const provider = getProvider(network, alchemyKey);
    const tokenContract = getSVGTokenContract(tokenAddress, provider);

    const nextToken = ref(0);

    const updateToken = () => {
      tokenContract.totalSupply().then(async (nextId: BigNumber) => {
        nextToken.value = nextId.toNumber();
        const token = nextId.toNumber() - 1;
        const token_id =  parseInt(route.params.token_id[0], 10) //get from url parameter

        console.log("load token:" + token + ' ' + token_id);

        if (token > token_id-1) {
            const ret = await tokenContract.tokenURI(token_id);
            console.log(ret);
            const data = JSON.parse(atob(ret.split(",")[1]));
            const price = await tokenContract.getPriceOf(token_id);

            token_obj.value = {data:data, price:price}

            console.log(token_obj)
        }

      });
    };
    updateToken();

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
    };
  },
});
</script>

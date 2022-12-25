<template>
  <div class="home">
    <div class="flex items-center justify-center space-x-8">
      mesasge:
      <input
        type="text"
        class="w-full rounded-md border-2 "
        v-model="message"
        />

    </div>
    <div class="flex items-center justify-center space-x-8">
      color:
      <input
        type="text"
        class="w-full rounded-md border-2 "
        v-model="color"
        />
      <br/>
    </div>

    <NetworkGate :expectedNetwork="chainId">
      <div class="flex">
        <div @click="mint" class="cursor-pointer">mint</div>
      </div>
      <div v-for="(token, k) in tokens" :key="k" class="mx-8">
        {{ token.name }}
        <img :src="token.image" class="w-36 border-2" />
      </div>
    </NetworkGate>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";


// import { data } from "./data";

// mint
import NetworkGate from "@/components/NetworkGate.vue";
import { BigNumber } from "ethers";
import { ChainIdMap, displayAddress } from "@/utils/MetaMask";
import {
  useMessageTokenNetworkContext,
  getProvider,
  getMessageTokenContract,
} from "@/utils/const";

//
import { parse } from "svg-parser";
import { convSVG2Path, dumpConvertSVG } from "@/utils/svgtool";
import { compressPath } from "@/utils/pathUtils";

export default defineComponent({
  components: {
    NetworkGate,
  },
  setup(props) {
    const message = ref("test");
    const color = ref("skyblue");

    const network = "localhost";
    const tokenAddress = "0xF9c0bF1CFAAB883ADb95fed4cfD60133BffaB18a";
    const chainId = ChainIdMap[network];

    const { networkContext } = useMessageTokenNetworkContext(chainId, tokenAddress);

    const isMinting = ref<boolean>(false);
    const mint = async () => {
      if (networkContext.value == null) {
        return;
      }
      const { contract } = networkContext.value;
      isMinting.value = true;

      const ret = {
        message: message.value,
        color: color.value,
      };
      try {
        console.log(ret);
        const tx = await contract.functions.mintWithAsset(ret);
        console.log("mint:tx");
        const result = await tx.wait();
        console.log("mint:gasUsed", result.gasUsed.toNumber());
      } catch (e) {
        console.error(e);
      }
      isMinting.value = false;
    };
    //
    const alchemyKey = process.env.VUE_APP_ALCHEMY_API_KEY;
    const provider = getProvider(network, alchemyKey);
    const tokenContract = getMessageTokenContract(tokenAddress, provider);
    const tokens = ref<any[]>([]);
    tokenContract.totalSupply().then(async (nextId: BigNumber) => {
      const token = nextId.toNumber() - 1;
      for (let i = 0; i < 10; i++) {
        if (token - i > 0) {
          const ret = await tokenContract.tokenURI(token - i);
          const data = JSON.parse(atob(ret.split(",")[1]));
          tokens.value.push(data);
        }
      }
    });

    return {
      message,
      color,

      // mint
      mint,
      chainId,

      tokens,
    };
  },
});
</script>

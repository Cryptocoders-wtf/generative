<template>
  <div class="home">
    <h2 class="m-4 text-xl font-bold">Fully On-chain Message NFT Token.</h2>
    <div class="mx-8">
      <div>
        <div class="text-left">Mesasge:</div>
        <div>
          <textarea
            type="text"
            rows="8"
            class="w-full resize rounded-md border-2"
            v-model="message"
          />
        </div>
      </div>
      <div class="mt-4 text-left">
        <span :style="{ color: color }" class="font-bold">Color:</span>
        <select v-model="color" class="resize rounded-md border-2">
          <option v-for="(option, k) in colors" :value="option.value" :key="k">
            {{ option.text }}
          </option>
        </select>
        <br />
      </div>
      <NetworkGate :expectedNetwork="chainId">
        <div class="flex items-center justify-center">
          <button
            @click="mint"
            class="mt-4 inline-block w-full rounded bg-green-600 px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
          >
            <span class="text-xl font-bold"> MINT </span>
          </button>
        </div>
        <div class="mt-4">
          <div v-for="(token, k) in tokens" :key="k">
            <div class="mt-2 font-bold">{{ token.name }}</div>
            <img :src="token.image" class="mt-4 w-48 border-2" />
          </div>
        </div>
      </NetworkGate>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";

// mint
import NetworkGate from "@/components/NetworkGate.vue";
import { BigNumber } from "ethers";
import { ChainIdMap, displayAddress } from "@/utils/MetaMask";
import {
  useMessageTokenNetworkContext,
  useMessageStoreNetworkContext,
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
    const color = ref("orange");

    const colors = [
      "pink",
      "orange",
      "yellow",
      "green",
      "darkmagenta",
      "aquamarine",
      "gold",
      "deeppink",
      "indigo",
      "orangered",
      "red",
      "mediumblue",
      "palegreen",
      "cornflowerblue",
    ].map((c) => ({
      value: c,
      text: c,
    }));

    const network = "goerli";

    // store 0x4e9A9414734f9BcfcDa3b9B07d54D288B5C212A7
    // provider 0x20Ed6e09220aDE749F14E4eC40fD3B85F7547D9f
    // token 0x29ef4ee08c5bc5e158b96665c49adf6a26392153
    const tokenAddress = "0x29ef4ee08c5bc5e158b96665c49adf6a26392153";
    // const storeAddress = "0x43cA9bAe8dF108684E5EAaA720C25e1b32B0A075";

    const chainId = ChainIdMap[network];

    const { networkContext } = useMessageTokenNetworkContext(
      chainId,
      tokenAddress
    );

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
        const tx = await contract.functions.mintWithAsset(ret);
        console.log("mint:tx");
        const result = await tx.wait();
        console.log("mint:gasUsed", result.gasUsed.toNumber());
      } catch (e) {
        alert("We are sorry, but something went wrong.");
        console.error(e);
      }
      isMinting.value = false;
    };

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
      colors,
      // mint
      mint,
      chainId,

      tokens,
    };
  },
});
</script>

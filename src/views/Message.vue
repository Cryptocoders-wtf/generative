<template>
  <div class="home">
    <h2>Store</h2>
    <div class="mx-8">
    <div class="flex items-center justify-center space-x-8">
      mesasge:
      <input
        type="text"
        class="w-full rounded-md border-2 "
        v-model="storeMessage"
        />
      <div class="flex">
        <div @click="debug" class="cursor-pointer">debug</div>
      </div>
      
    </div>
    <div v-if="debugImg">
      <img :src="debugImg" class="w-36"/>
    </div>
  </div>
    
    <hr />
    <h2>Token</h2>
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
    const storeMessage = ref("this is a pen");
    const message = ref("test");
    const color = ref("skyblue");
    

    // store      contract="0xC0BF43A4Ca27e0976195E6661b099742f10507e5"
    // provider      contract="0x9D3DA37d36BB0B825CD319ed129c2872b893f538"
    // token      contract="0x59C4e2c6a6dC27c259D6d067a039c831e1ff4947"
    
    const network = "localhost";
    const tokenAddress = "0x59C4e2c6a6dC27c259D6d067a039c831e1ff4947";
    const storeAddress = "0xC0BF43A4Ca27e0976195E6661b099742f10507e5";
    
    const chainId = ChainIdMap[network];

    const { networkContext } = useMessageTokenNetworkContext(chainId, tokenAddress);

    const { networkContext: storeContext } = useMessageStoreNetworkContext(chainId, storeAddress);

    const debugImg = ref("");
    const debug = async () => {
      if (storeContext.value == null) {
        return;
      }
      const { contract } = storeContext.value;
      isMinting.value = true;

      try {
        const ret = ["", "","",""];
        for(let i = 0; i < 4; i ++) {
          ret[i] = storeMessage.value.split(" ")[i] || "";
        }
        const res = await contract.functions.getSVGMessage(ret, "pink");
        
        // const result = await tx.wait();
        // console.log("mint:gasUsed", result.gasUsed.toNumber());
        debugImg.value = "data:image/svg+xml;base64," + Buffer.from(res[0]).toString("base64")
        // console.log(img);
        console.log(res[0]);
        
      } catch (e) {
        console.error(e);
      }
      isMinting.value = false;
    };

    
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
          console.log(data);
          tokens.value.push(data);
        }
      }
    });

    return {
      message,
      color,

      // debug
      debug,
      storeMessage,
      debugImg,
      
      // mint
      mint,
      chainId,

      tokens,
    };
  },
});
</script>

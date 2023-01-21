<template>
  <div class="home">
    <h2>Store</h2>
    <div class="mx-8">
      <div>
        mesasge:
        <textarea
          type="text"
          rows="8"
          class="w-full resize rounded-md border-2"
          v-model="storeMessage"
        />
      </div>
      <div class="flex items-center justify-center space-x-8">
        color:
        <input type="text" class="w-full rounded-md border-2" v-model="color" />
        <br />
      </div>
      <div>
        <div>
          <button
            @click="debug"
            class="mt-2 inline-block rounded bg-green-600 px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
          >
            debug
          </button>
        </div>
      </div>
      <div v-if="debugImg">
        <img :src="debugImg" class="w-36 border-2" />
      </div>
    </div>

    <hr class="my-4" />
    <h2>Token</h2>
    <div class="mx-8">
      <div class="flex items-center justify-center space-x-8">
        mesasge:
        <textarea
          type="text"
          rows="8"
          class="w-full resize rounded-md border-2"
          v-model="message"
        />
      </div>
      <div class="flex items-center justify-center space-x-8">
        color:
        <input type="text" class="w-full rounded-md border-2" v-model="color" />
        <br />
      </div>

      <NetworkGate :expectedNetwork="chainId">
        <div class="flex">
          <button
            @click="mint"
            class="mt-2 inline-block rounded bg-green-600 px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
          >
            mint
          </button>
        </div>
        <div v-for="(token, k) in tokens" :key="k">
          {{ token.name }}
          <img :src="token.image" class="w-36 border-2" />
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
    const storeMessage = ref("this\nis\na\npen");
    const message = ref("test");
    const color = ref("skyblue");

    // store      contract="0x15F2ea83eB97ede71d84Bd04fFF29444f6b7cd52"
    // provider      contract="0xF357118EBd576f3C812c7875B1A1651a7f140E9C"
    // token      contract="0x519b05b3655F4b89731B677d64CEcf761f4076f6"
    
    const network = "localhost";
    const tokenAddress = "0x519b05b3655F4b89731B677d64CEcf761f4076f6";
    const storeAddress = "0x15F2ea83eB97ede71d84Bd04fFF29444f6b7cd52";

    const chainId = ChainIdMap[network];

    const { networkContext } = useMessageTokenNetworkContext(
      chainId,
      tokenAddress
    );

    const { networkContext: storeContext } = useMessageStoreNetworkContext(
      chainId,
      storeAddress
    );

    const debugImg = ref("");
    const debug = async () => {
      if (storeContext.value == null) {
        return;
      }
      const { contract } = storeContext.value;
      isMinting.value = true;

      try {
        const res = await contract.functions.getSVGMessage(
          storeMessage.value || "",
          color.value,
          // { w: 1024, h: 512 }
          { w: 512, h: 1024 }
        );

        // const result = await tx.wait();
        // console.log("mint:gasUsed", result.gasUsed.toNumber());
        debugImg.value =
          "data:image/svg+xml;base64," + Buffer.from(res[0]).toString("base64");
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

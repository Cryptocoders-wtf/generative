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
            @input="updateSVGMessage"
          />
        </div>
      </div>
      <div class="mt-4 text-left">
        <span :style="{ color: color }" class="font-bold">Color:</span>
        <select v-model="color" class="resize rounded-md border-2" @change="updateSVGMessage">
          <option v-for="(option, k) in colors" :value="option.value" :key="k">
            {{ option.text }}
          </option>
        </select>
        <span class="font-bold ml-4">Font:</span>
        <select v-model="font" class="resize rounded-md border-2" @change="updateSVGMessage">
          <option v-for="(option, k) in fonts" :value="option.value" :key="k">
            {{ option.text }}
          </option>
        </select>
        <span class="font-bold ml-4">Asset:</span>
        <select v-model="asset" class="resize rounded-md border-2" @change="updateSVGMessage">
          <option v-for="(option, k) in assets" :value="option.value" :key="k">
            {{ option.text }}
          </option>
        </select>
        <br />
      </div>
      <div class="font-bold text-left text-2xl mt-4">Preview</div>
      <div class="w-72 border-2" style="margin-bottom: 20px; border: 1px solid rgb(180, 180, 180); ">
        <div v-html="messageSVG"></div>
      </div>
      <NetworkGate :expectedNetwork="chainId">
        <div class="flex items-center justify-center">
          <button
            @click="mint"
            class="mt-4 inline-block w-full rounded bg-green-600 px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
          >
            <span class="text-xl font-bold">
              <span v-if="isMinting">MINTING...</span>
              <span v-else>MINT</span>
            </span>
          </button>
        </div>
      </NetworkGate>
      <div v-if="tokens.length === 0">Loading...</div>
      <div v-else>
        <div class="mt-4">
          <div v-for="(token, k) in tokens" :key="k">
            <div class="mt-2 font-bold">{{ token.name }}</div>
            <img :src="token.image" class="mt-4 w-48 border-2" />
          </div>
        </div>
      </div>
    </div>
    <div>
      <a
        href="https://testnets.opensea.io/collection/messagetokenv2"
        class="underline"
        target="_blank"
        >See NFTs on OpenSea</a
      >
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref, computed } from "vue";

// mint
import NetworkGate from "@/components/NetworkGate.vue";
import { BigNumber } from "ethers";
import { ChainIdMap, displayAddress } from "@/utils/MetaMask";
import {
  useMessageTokenNetworkContext,
  useMessageStoreNetworkContext,
  getMessageStoreContract,
  getProvider,
  getMessageTokenContract,
  getMessageProviderContract,
} from "@/utils/const";

//
import { parse } from "svg-parser";
import { convSVG2Path, dumpConvertSVG } from "@/utils/svgtool";
import { compressPath } from "@/utils/pathUtils";
import { addresses } from "@/utils/addresses";

export default defineComponent({
  components: {
    NetworkGate,
  },
  setup(props) {
    const message = ref("Fully On-chain\ntest.");
    const color = ref("orange");
    const font = ref("Londrina_Solid");
    const asset = ref("Splatter");

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

    const fonts = [
      "Londrina_Solid",
      "Noto_Sans",
    ].map((c) => ({
      value: c,
      text: c,
    }));

    const assets = [
      "Splatter",
      "Snow",
    ].map((c) => ({
      value: c,
      text: c,
    }));

    const network = "mumbai";

    const tokenAddress = addresses.messageToken.mumbai;
    const providerAddress = addresses.messageProvider.mumbai;
    console.log("tokenAddress:", tokenAddress);
    console.log("providerAddress:", providerAddress);

    const chainId = ChainIdMap[network];

    const box = {
      w: 1024,
      h: 1024,
    };

    const messageSVG = ref(null);

    const alchemyKey = process.env.VUE_APP_ALCHEMY_API_KEY;
    const provider = getProvider(network, alchemyKey);
    const tokens = ref<any[]>([]);

    const tokenContract = getMessageTokenContract(tokenAddress, provider);

    const providerContract = getMessageProviderContract(providerAddress, provider);

    const loadSVGMessage = async () => {
      messageSVG.value = await providerContract.generateSVGMessage(
        message.value, 
        color.value, 
        font.value, 
        asset.value, 
        box
      );
    };
    const updateSVGMessage = () => {
      loadSVGMessage();
    };
    loadSVGMessage();

    const { networkContext } = useMessageTokenNetworkContext(
      chainId,
      tokenAddress
    );

    const isMinting = ref<boolean>(false);
    const mint = async () => {
      if (networkContext.value == null) {
        return;
      }
      if (isMinting.value) {
        return;
      }
      const { contract } = networkContext.value;
      isMinting.value = true;

      try {
        const ret = {
          message: message.value,
          color: color.value,
          fontName: font.value,
          assetName: asset.value,
        };
        const tx = await contract.functions.mintWithAsset(ret);
        const result = await tx.wait();
        console.log("mint:tx");
        console.log("mint:gasUsed", result.gasUsed.toNumber());
      } catch (e) {
        alert("We are sorry, but something went wrong.");
        isMinting.value = false;
        console.error(e);
      }
    };

    const fetchTokens = () => {
      tokenContract.totalSupply().then(async (nextId: BigNumber) => {
        const token = nextId.toNumber() - 1;
        console.log("fetchTokens:token", token);
        tokens.value = [];
        for (let i = 0; i < 10; i++) {
          if (token - i >= 0) {
            const ret = await tokenContract.tokenURI(token - i);
            const data = JSON.parse(atob(ret.split(",")[1]));
            tokens.value.push(data);
          }
        }
      });
    };
    fetchTokens();

    provider.once("block", () => {
      tokenContract.on(
        tokenContract.filters.Transfer(),
        async (from, to, tokenId) => {
          isMinting.value = false;
          console.log("*** event.Transfer calling fetchTokens");
          fetchTokens();
        }
      );
    });

    return {
      message,
      color,
      colors,
      font,
      fonts,
      asset,
      assets,
      messageSVG,
      updateSVGMessage,
      // mint
      mint,
      isMinting,
      chainId,

      tokens,
    };
  },
});
</script>

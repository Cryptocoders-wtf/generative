<template>
  <div class="home">
    <div class="flex items-center justify-center space-x-8">
      <!-- Drag & Drop -->
      <div
        @dragover.prevent
        @drop.prevent
        class="relative mx-4 mt-4 h-24 w-48 border-4"
      >
        <div @drop="dragFile" class="absolute h-full w-full text-left">
          <input
            type="file"
            multiple
            @change="uploadFile"
            class="absolute h-full w-full opacity-0"
          />
          <div class="mt-4 text-center">Put your SVG image here.</div>
        </div>
      </div>
    </div>

    <div class="flex justify-center">
      <div class="flex-item" v-if="svgData">
        Original SVG<br />
        <img :src="svgData" class="mx-4 mt-4 h-48 w-48" />
      </div>
      <div class="flex-item" v-if="convedSVGData">
        NFT Image<br />
        <img :src="convedSVGData" class="mx-4 mt-4 h-48 w-48" />
      </div>
    </div>
    <div class="mt-2">
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
            mint
          </div>
        </div>

        <div>
          <a href="https://goerlifaucet.com" class="underline" target="_blank"
            >Get Free Goerli ETH</a
          >
        </div>

        <div class="mx-10 text-left">
          <h2 class="font-xl font-bold">
            Convert SVG with simple structure to full on-chain NFT
          </h2>

          <li>All data is converted to the d attribute of the path element.</li>
          <li>
            Only circle, ellipses, line, rect, polygon, polyline element are
            converted to the d attribute of the path element. All other elements
            are ignored.
          </li>
          <li>
            g elements are expanded. nested g elements are expanded to flat.
          </li>
          <li>Fill is retained</li>
          <li>
            stroke and stroke-width are supported.
            stroke-linecap:round;stroke-linejoin:round can be specified to add
            stroke.
          </li>
          <li>
            Size of image is normalized to 1024*1024 based on viewBox or SVG
            properties width, height.
          </li>
        </div>

      </NetworkGate>
      <div v-for="(token, k) in tokens" :key="k" class="mx-8">
        {{ token.name }}
        <img :src="token.image" class="w-36 border-2" />
      </div>
    </div>
    <div>
      <a
        href="https://testnets.opensea.io/ja/collection/svgtokenv1-3?search[sortAscending]=false&search[sortBy]=CREATED_DATE"
        class="underline"
        target="_blank"
        >See NFTs on OpenSea</a
      >
    </div>
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

const sleep = async (seconds: number) => {
  return await new Promise((resolve) => setTimeout(resolve, seconds * 1000));
};

export default defineComponent({
  components: {
    NetworkGate,
  },
  setup(props) {
    const file = ref();

    const svgData = ref("");
    const convedSVGData = ref("");

    const svgText = ref("");
    const convedSVGText = ref("");

    const pathData = ref<any>([]);
    const existData = computed(() => {
      return pathData.value.length > 0;
    });

    const reset = () => {
      svgText.value = "";
      svgData.value = "";
      pathData.value = [];
      convedSVGText.value = "";
      convedSVGData.value = "";
    };
    const readSVGData = async () => {
      try {
        svgText.value = await file.value.text();
        svgData.value = svg2imgSrc(svgText.value);

        pathData.value = convSVG2Path(svgText.value, true);
        convedSVGText.value = dumpConvertSVG(pathData.value);
        convedSVGData.value = svg2imgSrc(convedSVGText.value);
      } catch (e) {
        reset();
        console.log(e);
        alert("Sorry, this svg is not supported.");
      }
    };

    const uploadFile = (e: any) => {
      if (e.target.files && e.target.files.length > 0) {
        file.value = e.target.files[0];
        readSVGData();
      }
    };
    const dragFile = (e: any) => {
      if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
        file.value = e.dataTransfer.files[0];
        readSVGData();
      }
    };

    // store      contract="0x442622c789E5489A222141d06966608a2980E915"
    // provider      contract="0x24F08949190D291DaBb9d7a828ad048FE6250E0C"
    // token      contract="0x07f21753E1DA964fc7131571DD999471C6492e7E"
    
    const network = "goerli";
    const tokenAddress = "0x07f21753E1DA964fc7131571DD999471C6492e7E";


    const chainId = ChainIdMap[network];

    const { networkContext } = useSVGTokenNetworkContext(chainId, tokenAddress);

    const alchemyKey = process.env.VUE_APP_ALCHEMY_API_KEY;
    const provider = getProvider(network, alchemyKey);
    const tokenContract = getSVGTokenContract(tokenAddress, provider);
    const tokens = ref<any[]>([]);
    const nextToken = ref(0);
    const updateTokens = () => {
      tokenContract.totalSupply().then(async (nextId: BigNumber) => {
        nextToken.value = nextId.toNumber();
        const token = nextId.toNumber() - 1;
        for (let i = 0; i < 10; i++) {
          if (token - i > -1) {
            const ret = await tokenContract.tokenURI(token - i);
            const data = JSON.parse(atob(ret.split(",")[1]));
            tokens.value.push(data);
          }
        }
      });
    };
    updateTokens();

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

    const isMinting = ref<boolean>(false);
    const mint = async () => {
      if (networkContext.value == null) {
        return;
      }
      const { contract } = networkContext.value;
      isMinting.value = true;

      const ret = {
        paths: [] as string[],
        fills: [] as string[],
        strokes: [] as string[],
        matrixes: [] as string[],
      };
      pathData.value.map((a: any) => {
        ret.paths.push(
          "0x" + Buffer.from(compressPath(a.path, 1024)).toString("hex")
        );
        ret.fills.push(a.fill || "");
        ret.strokes.push(a.strokeW);
        ret.matrixes.push(a.matrix || "");
      });
      console.log(ret);

      try {
        console.log(ret);
        const tx = await contract.functions.mintWithAsset(ret);
        console.log("mint:tx");
        const result = await tx.wait();
        console.log("mint:gasUsed", result.gasUsed.toNumber());

        await polling();
        tokens.value = [];
        updateTokens();
      } catch (e) {
        console.error(e);
        alert("Sorry, this svg is not supported.");
      }
      isMinting.value = false;
    };

    return {
      uploadFile,
      dragFile,

      svgData,
      convedSVGData,

      svgText,
      convedSVGText,

      // mint
      mint,
      chainId,

      tokens,
      existData,
    };
  },
});
</script>

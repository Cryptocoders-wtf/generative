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
          <li>Transposed or scaled/rotated elements are not supported.</li>
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

        <div v-for="(token, k) in tokens" :key="k" class="mx-8">
          {{ token.name }}
          <img :src="token.image" class="w-36 border-2" />
        </div>
      </NetworkGate>
    </div>
    <div>
      <a
        href="https://testnets.opensea.io/ja/collection/svgtokenv1-zmx77dtbul?search[sortAscending]=false&search[sortBy]=CREATED_DATE"
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

    // store      contract="0x2625760C4A8e8101801D3a48eE64B2bEA42f1E96"
    // provider      contract="0xFE5f411481565fbF70D8D33D992C78196E014b90"
    // token      contract="0xD6b040736e948621c5b6E0a494473c47a6113eA8"
    // mint

    // store      contract="0x942ED2fa862887Dc698682cc6a86355324F0f01e"
    // provider      contract="0x8D81A3DCd17030cD5F23Ac7370e4Efb10D2b3cA4"
    // token      contract="0xcC4c41415fc68B2fBf70102742A83cDe435e0Ca7"

    // store      contract="0x124dDf9BdD2DdaD012ef1D5bBd77c00F05C610DA"
    // provider      contract="0xe044814c9eD1e6442Af956a817c161192cBaE98F"
    // token      contract="0xaB837301d12cDc4b97f1E910FC56C9179894d9cf"

    // store      contract="0xbe18A1B61ceaF59aEB6A9bC81AB4FB87D56Ba167"
    // provider      contract="0x25C0a2F0A077F537Bd11897F04946794c2f6f1Ef"
    // token      contract="0x01cf58e264d7578D4C67022c58A24CbC4C4a304E"

    // store      contract="0x15Ff10fCc8A1a50bFbE07847A22664801eA79E0f"
    // provider      contract="0xAe9Ed85dE2670e3112590a2BB17b7283ddF44d9c"
    // token      contract="0xD1760AA0FCD9e64bA4ea43399Ad789CFd63C7809"

    // goerli
    // store      contract="0xBfF6B329982d9CC14F30E9477f79d7721A9668C3"
    // provider      contract="0xE154babC135C92CafDA05723260Af0c6510265df"
    // token      contract="0xe2E10A4e46202D12B3771999A06f5a67E818b885"

    // store      contract="0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"
    // provider      contract="0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9"
    // token      contract="0x5FC8d32690cc91D4c39d9d3abcBD16989F875707"

    const network = "localhost";
    const tokenAddress = "0x0165878A594ca255338adfa4d48449f69242Eb8F";

    // const network = "goerli";
    // const tokenAddress = "0xe2E10A4e46202D12B3771999A06f5a67E818b885";

    const chainId = ChainIdMap[network];

    const { networkContext } = useSVGTokenNetworkContext(chainId, tokenAddress);

    //
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
            // console.log(data);
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

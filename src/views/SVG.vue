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
        <img :src="token.data.image" class="w-36 border-2" />
        {{ token.data.name }}
        {{ token.owner }}
        <div v-if="token.price > 0">
          On Sale!  {{ token.price }} eth
        </div>
        <div v-else>
          Not on sale.
        </div>
        <div v-if="token.isOwner">
          <input
            type="text"
            v-model="prices[token.id]"
            maxlength="512"
            minlength="1"
            class="text-sm my-2 text-slate-500 rounded-sm border-1 text-sm bg-gray-100 file:text-gray-800 hover:bg-white"
          />

          <button
            @click="setPrice(token.id)"
            class="mb-2 inline-block rounded bg-green-600 px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
          >
            set price
          </button>

        </div>
        <div v-else>
          <div v-if="token.price > 0">
            <button
              @click="purchase(token.id)"
              class="mb-2 inline-block rounded bg-green-600 px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
            >
              Purchase!
            </button>            
          </div>
        </div>

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
</template>

<script lang="ts">
import { defineComponent, ref, computed } from "vue";
import { svg2imgSrc } from "@/utils/svgtool";

// mint
import NetworkGate from "@/components/NetworkGate.vue";
import { BigNumber, utils } from "ethers";
import { ChainIdMap, displayAddress } from "@/utils/MetaMask";
import {
  useSVGTokenNetworkContext,
  getProvider,
  getSVGTokenContract,
} from "@/utils/const";

//
import { parse } from "svg-parser";
import { useStore } from "vuex";
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

    const store = useStore();
    const account = computed(() => store.state.account);    
    const prices = ref<any>([]);

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

    // store      contract="0x610178dA211FEF7D417bC0e6FeD39F05609AD788"
    // provider      contract="0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e"
    // token      contract="0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0"
    // const network = "localhost";
    // const tokenAddress = "0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0";

    //const network = "goerli";
    //const tokenAddress = "0xe2E10A4e46202D12B3771999A06f5a67E818b885";

    const network = "mumbai";
    const tokenAddress = "0x67b8571A13410a2687b8ceA1C416b88d75165Fc6";
    //const tokenAddress = "0xac83F049087F20b912c7454141fe75fEee85ed5f";

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
            const id = token - i;
            const owner = await tokenContract.ownerOf(id);
            const isOwner = utils.getAddress(account.value) == utils.getAddress(owner);
            const price = await tokenContract.getPriceOf(id);
            const ret = await tokenContract.tokenURI(id);
            const data = JSON.parse(atob(ret.split(",")[1]));
            
            tokens.value.push({id,owner,data,isOwner,price});

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
    const setPrice = async (id: number) => {
      if (networkContext.value == null) {
        return;
      }
      const { contract } = networkContext.value;
      try {
        console.log(id);
        const tokenid = id;
        const price = BigNumber.from(prices.value[id]);
        console.log(tokenid,price);
        await contract.setPriceOf(tokenid,price);
      } catch (e) {
        console.error(e);
        alert("Sorry, setPrice failed with:"+e);
      }
    };
    const purchase = async (id: number) => {
      if (networkContext.value == null) {
        return;
      }
      const { contract } = networkContext.value;
      try {
        console.log(id,(tokens.value));
        const price = await tokenContract.getPriceOf(id);
        const owner = await tokenContract.ownerOf(id);
        await contract.purchase(id, account.value, owner , { value: price });
      } catch (e) {
        console.error(e);
        alert("Sorry, purchase failed with:"+e);
      }
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

      prices,
      setPrice,
      purchase,
    };
  },
});
</script>

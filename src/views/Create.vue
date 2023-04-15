<template>
  <div class="home">

    <section class="bg-white dark:bg-gray-900">
    <div class="grid max-w-screen-xl px-4 py-8 mx-auto lg:gap-8 xl:gap-0 lg:py-16 lg:grid-cols-12">
        <div class="mr-auto place-self-center lg:col-span-7">
            <h1 class="max-w-2xl mb-4 text-4xl font-extrabold tracking-tight leading-none md:text-5xl xl:text-6xl dark:text-white">Convert SVG with simple structure to full on-chain NFT</h1>
            <p class="max-w-2xl mb-6 font-light text-gray-500 lg:mb-8 md:text-lg lg:text-xl dark:text-gray-400">All data is converted to the d attribute of the path element. <br/>
            Only circle, ellipses, line, rect, polygon, polyline element are converted to the d attribute of the path element. All other elements are ignored.</p>
        </div>
        <div class="hidden lg:mt-0 lg:col-span-5 lg:flex">
            <img class="rounded-2xl" src="@/assets/heroimg.png" alt="mockup">
        </div>                
    </div>
</section>

    <div class="mt-2">
      <NetworkGate :expectedNetwork="chainId">

        <div @dragover.prevent
              @drop.prevent class="flex justify-center">
          <div @drop="dragFile"  class="m-4 w-full">
              <label
                  class="flex justify-center w-full h-32 px-4 transition bg-white border-2 border-gray-300 border-dashed rounded-md appearance-none cursor-pointer hover:border-gray-400 focus:outline-none">
                  
                  <span class="flex items-center space-x-2">
                      <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 text-gray-600" fill="none" viewBox="0 0 24 24"
                          stroke="currentColor" stroke-width="2">
                          <path stroke-linecap="round" stroke-linejoin="round"
                              d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                      </svg>
                      <span class="font-medium text-gray-600">
                          Drop your SVG file, or
                          <span class="text-blue-600 underline">browse</span>
                      </span>
                  </span>
                  <input
                    type="file"
                    @change="uploadFile"
                    class="hidden"
                  />
              </label>
          </div>
        </div>

      <div class="grid grid-cols-2 gap-4">
        <div v-if="svgData">          
          <img :src="svgData" class="h-48 w-48 mx-auto my-auto " />
          <h2>Original SVG</h2>
        </div>
        <div v-if="convedSVGData">
          <img :src="convedSVGData" class="h-48 w-48 mx-auto my-auto" />
          <h2>NFT Image</h2>
        </div>
      </div>

        <div class="mb-6 w-64 mx-auto">
          <label for="price" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Price</label>
        <input v-model="set_price" type="text" id="price" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="Input Price (ETH)" required>
      </div>
    

        <div class="flex justify-center">

          <div
            @click="mint"
            :disabled="!existData"
            v-if="isExecuting == 0"
            class="text-white bg-gradient-to-br from-purple-600 to-blue-500 hover:bg-gradient-to-bl focus:ring-4 focus:outline-none focus:ring-blue-300 dark:focus:ring-blue-800 font-medium rounded-lg text-sm px-20 py-5 text-center mr-2 mb-2"
            :class="
              existData
                ? 'bg-green-600 focus:bg-green-700'
                : 'bg-green-600 bg-opacity-20 focus:bg-green-700'
            "
          >
          MINT!

          </div>
          <div v-if="isExecuting == 1">
            <img class="h-20 w-20" src="@/assets/preload.gif" />
          </div>
          <div v-if="isExecuting == 2">
            Complete !!
            <div @click="isExecuting = 0">
              <b>OK!</b>
            </div>
          </div>
        </div>

        <div class="mx-10 text-left ">
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
      </div>
    </div>
</template>

<script lang="ts">
import { defineComponent, ref, computed } from "vue";
import { svg2imgSrc } from "@/utils/svgtool";
import { addresses } from "@/utils/addresses";

// mint
import NetworkGate from "@/components/NetworkGate.vue";
import { BigNumber, Transaction, utils } from "ethers";
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
import router from "@/router";

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

    const isExecuting = ref(0); // 0:non-execute, 1:executing, 2:complete

    const store = useStore();
    const account = computed(() => store.state.account);
    const prices = ref<any>([]);
    const set_price = ref<number>(0);

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
    const tokenAddress = addresses.svgtoken[network];
    // const tokenAddress = "0x67b8571A13410a2687b8ceA1C416b88d75165Fc6";
    //const tokenAddress = "0xac83F049087F20b912c7454141fe75fEee85ed5f";

    const chainId = ChainIdMap[network];

    const { networkContext } = useSVGTokenNetworkContext(chainId, tokenAddress);
    store.state.networkContext = networkContext;

    const alchemyKey = process.env.VUE_APP_ALCHEMY_API_KEY;
    const provider = getProvider(network, alchemyKey);
    const tokenContract = getSVGTokenContract(tokenAddress, provider);

    const nextToken = ref(0);

    const polling = async (tx: any) => {
      const receipt = await tx.wait();
      if (receipt.status == 1) {
        // success transaction
        const events = receipt.events.filter(
          (event: any) => event.event === "Transfer"
        );

        const returnValue = events[0].args[2].toNumber(); // 返り値 Transfer(from, to, tokenId)
        return returnValue;
      } else {
        console.log("receipt", receipt);
        alert("Sorry, transaction failed.");
      }
    };

    const isMinting = ref<boolean>(false);
    const mint = async () => {
      if (networkContext.value == null) {
        return;
      }
      const { contract } = networkContext.value;
      isMinting.value = true;
      isExecuting.value = 1;

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
        const price = BigNumber.from(set_price.value);
        console.log(price);
        const tx = await contract.mintToSell(ret,price);
        console.log("mint:tx");
        const result = await tx.wait();
        const tokenId = await polling(tx);
        console.log("mint:tokenId", tokenId);
        console.log("mint:gasUsed", result.gasUsed.toNumber());

        reset();
        isExecuting.value = 0;
        router.push({
          name: "item",
          params: { token_id: tokenId },
        });

      } catch (e) {
        // ウォレットで拒否した場合
        if (String(e).indexOf("ACTION_REJECTED") == -1) {
          console.error(e);
          alert("Sorry, transaction is failured.");
        }
        isExecuting.value = 0;
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

      existData,
      isExecuting,

      prices,
      set_price,
    };
  },
});
</script>

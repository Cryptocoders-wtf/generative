<template>
  <div class="home">
    <section class="bg-white dark:bg-gray-900">
      <div
        class="mx-auto grid max-w-screen-xl px-4 py-8 lg:grid-cols-12 lg:gap-8 lg:py-16 xl:gap-0"
      >
        <div class="mr-auto place-self-center lg:col-span-7">
          <h1
            class="mb-4 max-w-2xl text-4xl font-extrabold leading-none tracking-tight dark:text-white md:text-5xl xl:text-6xl"
          >
            Convert SVG with simple structure to full on-chain NFT
          </h1>
          <p
            class="mb-6 max-w-2xl font-light text-gray-500 dark:text-gray-400 md:text-lg lg:mb-8 lg:text-xl"
          >
            All data is converted to the d attribute of the path element. <br />
            Only circle, ellipses, line, rect, polygon, polyline element are
            converted to the d attribute of the path element. All other elements
            are ignored.
          </p>
        </div>
        <div class="hidden lg:col-span-5 lg:mt-0 lg:flex">
          <img class="rounded-2xl" src="@/assets/heroimg.png" alt="mockup" />
        </div>
      </div>
    </section>

    <div class="mt-2">
      <NetworkGate :expectedNetwork="chainId">
        <div @dragover.prevent @drop.prevent class="flex justify-center">
          <div @drop="dragFile" class="m-4 w-full">
            <label
              class="flex h-32 w-full cursor-pointer appearance-none justify-center rounded-md border-2 border-dashed border-gray-300 bg-white px-4 transition hover:border-gray-400 focus:outline-none"
            >
              <span class="flex items-center space-x-2">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-6 w-6 text-gray-600"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  stroke-width="2"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"
                  />
                </svg>
                <span class="font-medium text-gray-600">
                  Drop your SVG file, or
                  <span class="text-blue-600 underline">browse</span>
                </span>
              </span>
              <input type="file" @change="uploadFile" class="hidden" />
            </label>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div v-if="svgData">
            <img :src="svgData" class="mx-auto my-auto h-48 w-48" />
            <h2>Original SVG</h2>
          </div>
          <div v-if="convedSVGData">
            <img :src="convedSVGData" class="mx-auto my-auto h-48 w-48" />
            <h2>NFT Image</h2>
          </div>
        </div>

        <div class="mx-auto mb-6 w-64">
          <label
            for="price"
            class="mb-2 block text-sm font-medium text-gray-900 dark:text-white"
            >Price</label
          >
          <input
            v-model="set_price"
            type="text"
            id="price"
            class="block w-full rounded-lg border border-gray-300 bg-gray-50 p-2.5 text-sm text-gray-900 focus:border-blue-500 focus:ring-blue-500 dark:border-gray-600 dark:bg-gray-700 dark:text-white dark:placeholder-gray-400 dark:focus:border-blue-500 dark:focus:ring-blue-500"
            placeholder="Input Price (ETH)"
        :disabled="isExecuting == 1"
        :class="isExecuting == 1 ? 'bg-gray-500 bg-opacity-80' : 'bg-gray-100'"

            required
          />
        </div>

        <div class="flex justify-center">
          <button
            @click="mint"
            :disabled="!existData"
            v-if="isExecuting == 0"
            class="mr-2 mb-2 rounded-lg bg-gradient-to-br from-purple-600 to-blue-500 px-20 py-5 text-center text-sm font-medium text-white hover:bg-gradient-to-bl focus:outline-none focus:ring-4 focus:ring-blue-300 dark:focus:ring-blue-800"
            :class="
              existData
                ? 'bg-green-600 focus:bg-green-700'
                : 'bg-green-600 bg-opacity-20 focus:bg-green-700'
            "
          >
            MINT!
          </button>
          <div v-if="isExecuting == 1">
            <img class="h-20 w-20" src="@/assets/preload.gif" />
          </div>
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
    const set_price = ref<string>("");

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

    const network = "mumbai";
    const tokenAddress = addresses.svgtoken[network];

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

    const mint = async () => {
      if (networkContext.value == null) {
        return;
      }
      const { contract } = networkContext.value;
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
        const price = utils.parseEther(set_price.value);
        console.log(price);
        const tx = await contract.mintToSell(ret, price);
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

<template>
  <div class="home">
    <div class="flex items-center justify-center space-x-8">
      <!-- Drag & Drop -->
      <div @dragover.prevent @drop.prevent class="mx-4 mt-4 h-24 w-48 border-4">
        <div @drop="dragFile">
          <input
            type="file"
            multiple
            @change="uploadFile"
            class="h-full w-full opacity-0"
          />
          put your svg
        </div>
      </div>
    </div>
    <div class="flex">
      <div class="flex-item" v-if="svgData">
        before<br />
        <img :src="svgData" class="mx-4 mt-4 h-48 w-48" />
      </div>
      <div class="flex-item" v-if="convedSVGData">
        after<br />
        <img :src="convedSVGData" class="mx-4 mt-4 h-48 w-48" />
      </div>
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

    const pathData = ref<any>();

    const readSVGData = async () => {
      svgText.value = await file.value.text();
      svgData.value = svg2imgSrc(svgText.value);

      pathData.value = convSVG2Path(svgText.value, true);
      convedSVGText.value = dumpConvertSVG(pathData.value);
      convedSVGData.value = svg2imgSrc(convedSVGText.value);
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
    const network = "localhost";
    const tokenAddress = "0x124dDf9BdD2DdaD012ef1D5bBd77c00F05C610DA";
    const chainId = ChainIdMap[network];

    const { networkContext } = useSVGTokenNetworkContext(chainId, tokenAddress);

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
      };
      pathData.value.map((a: any) => {
        // const stroke = a.stroke === "none" ? 0 : (a.stroke.startsWith("#") ? 0 : (a.stroke || 0));

        ret.paths.push(
          "0x" + Buffer.from(compressPath(a.path, 1024)).toString("hex")
        );
        ret.fills.push(a.fill);
        ret.strokes.push(a.strokeW);
      });
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
    const tokenContract = getSVGTokenContract(tokenAddress, provider);
    const tokens = ref<any[]>([]);
    tokenContract.totalSupply().then(async (nextId: BigNumber) => {
      const token = nextId.toNumber() - 1;
      for (let i = 0; i < 10; i++) {
        if (token - i > 0) {
          const ret = await tokenContract.tokenURI(token - i);
          const data = JSON.parse(atob(ret.split(",")[1]));
          tokens.value.push(data);
          // console.log(data);
        }
      }
    });

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
    };
  },
});
</script>

<template>
  <div>
    <p>Mint</p>
    <NetworkGate :expectedNetwork="chainId">
      <button
        @click="mint"
        class="mt-2 inline-block rounded bg-green-600 px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
      >
        {{ $t("mint.mint") }}
      </button>
    </NetworkGate>
    <p>{{ tokenAddress }}</p>
    <p>xx<img :src="debugImage" class="mr-1 mb-1 inline-block w-32" />yy</p>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed, ref } from "vue";
import { useStore } from "vuex";
import { useRoute } from "vue-router";
import { ethers } from "ethers";
import { ChainIdMap } from "../utils/MetaMask";
import NetworkGate from "@/components/NetworkGate.vue";

const ProviderTokenEx = {
  wabi: require("@/abis/ProviderTokenEx.json"), // wrapped abi
};

export default defineComponent({
  props: ["network", "tokenAddress"],
  components: {
    NetworkGate,
  },
  setup(props) {
    const route = useRoute();
    const store = useStore();

    const chainId = ChainIdMap[props.network];
    const provider =
      props.network == "localhost"
        ? new ethers.providers.JsonRpcProvider()
        : new ethers.providers.AlchemyProvider(props.network);
    const contractRO = new ethers.Contract(
      props.tokenAddress,
      ProviderTokenEx.wabi.abi,
      provider
    );
    const debugImage = ref<string>("");
    const debugFetch = async () => {
      const [tokenURI] = await contractRO.functions.tokenURI(0);
      console.log("tokenURI", tokenURI);
      const data = tokenURI.substring(29); // HACK: hardcoded
      const decoded = Buffer.from(data, 'base64');
      const json = JSON.parse(decoded.toString());
      debugImage.value = json.image;
      const svgData = json.image.substring(26); // hardcoded
      const svg = Buffer.from(svgData, 'base64').toString();
      console.log("data", svg);
    };
    debugFetch();

    const affiliateId =
      typeof route.query.ref == "string" ? parseInt(route.query.ref) || 0 : 0;

    const networkContext = computed(() => {
      if (store.state.account && store.state.chainId == chainId) {
        const provider = new ethers.providers.Web3Provider(
          store.state.ethereum
        );
        const signer = provider.getSigner();
        const contract = new ethers.Contract(
          props.tokenAddress,
          ProviderTokenEx.wabi.abi,
          signer
        );

        return { provider, signer, contract };
      }
      return null;
    });
    const mint = async () => {
      if (networkContext.value == null) {
        return;
      }
      const { provider, signer, contract } = networkContext.value;
      console.log("***mint", contract);
      const tx = await contract.functions.mint(affiliateId);
      const result = await tx.wait();
      console.log("mint:gasUsed", result.gasUsed.toNumber());
    };
    return {
      chainId,
      mint,
      debugImage,
    };
  },
});
</script>

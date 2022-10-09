<template>
  <div>
    <p class="mt-2">Free Mint ({{ network }})</p>
    <p v-if="isConnected">Wallet: {{ account }}</p>
    <NetworkGate :expectedNetwork="chainId">
      <p v-if="totalBalance > 0">You have {{ totalBalance }} whitelist token(s).</p>
      <p v-else>You have no whitelist token.</p>
      <button
        @click="mint"
        class="mt-2 inline-block rounded bg-green-600 px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
      >
        {{ $t("mint.mint") }}
      </button>
    </NetworkGate>
    <p class="mt-2">
      <span v-for="token in tokens" :key="token.tokenId">
        <a :href="`${OpenSeaPath}/${token.tokenId}`" target="_blank">
          <img :src="token.image" class="mr-1 mb-1 inline-block w-32" />
        </a>
      </span>
    </p>
    <References :EtherscanToken="EtherscanToken" :TokenName="tokenName" />
  </div>
</template>

<script lang="ts">
import { defineComponent, computed, ref, watch } from "vue";
import { useStore } from "vuex";
import { useRoute } from "vue-router";
import { ethers } from "ethers";
import { ChainIdMap } from "../utils/MetaMask";
import NetworkGate from "@/components/NetworkGate.vue";
import { getAddresses } from "@/utils/const";
import References from "@/components/References.vue";
import { addresses } from "@/utils/addresses";

const ProviderTokenEx = {
  wabi: require("@/abis/ProviderTokenEx.json"), // wrapped abi
};
const AssetTokenGate = {
  wabi: require("@/abis/AssetTokenGate.json"), // wrapped abi
};

console.log("*** addresses", addresses);

interface Token {
  tokenId: number;
  image: string;
}

export default defineComponent({
  props: ["network", "tokenAddress"],
  components: {
    NetworkGate,
    References,
  },
  setup(props) {
    const route = useRoute();
    const store = useStore();
    const totalBalance = ref<number>(0);

    const isConnected = computed(() => {
      if (store.state.account == null) {
        return false;
      }
      const checkTokenGate = async () => {
        console.log("### calling totalBalanceOf");
        const [result] = await tokenGate.functions.totalBalanceOf(store.state.account);
        console.log("###", result);
        totalBalance.value = result.toNumber();
      };
      checkTokenGate();
      return true;
    });

    const tokensPerAsset = ref<number>(1);
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
    const tokenGate = new ethers.Contract(
      addresses.tokenGate[props.network],
      AssetTokenGate.wabi.abi,
      provider
    );
    const tokens = ref<Token[]>([]);
    const fetchTokens = async () => {
      const [count] = await contractRO.functions.totalSupply();
      console.log("totalSupply", count.toNumber());
      const updatedTokens = [];
      for (var tokenId = Math.max(0, count - 4); tokenId < count; tokenId++) {
        const [tokenURI, gas] = await contractRO.functions.debugTokenURI(
          tokenId
        );
        console.log("gas", tokenId, gas.toNumber());
        const data = tokenURI.substring(29); // HACK: hardcoded
        const decoded = Buffer.from(data, "base64");
        const json = JSON.parse(decoded.toString());
        updatedTokens.push({ tokenId, image: json.image });
        const svgData = json.image.substring(26); // hardcoded
        const svg = Buffer.from(svgData, "base64").toString();
      }
      tokens.value = updatedTokens;
    };
    fetchTokens();
    const once = async () => {
      const [value] = await contractRO.functions.tokensPerAsset();
      console.log("tokensPerAsset", value.toNumber());
      tokensPerAsset.value = value;
    };
    once();

    provider.once("block", () => {
      contractRO.on(
        contractRO.filters.Transfer(),
        async (from, to, tokenId) => {
          if (tokenId % tokensPerAsset.value == tokensPerAsset.value - 1) {
            console.log("*** event.Transfer calling fetchTokens");
            fetchTokens();
          }
        }
      );
    });

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
      console.log("minting", contract);
      const tx = await contract.functions.mint(affiliateId);
      console.log("mint:tx");
      const result = await tx.wait();
      console.log("mint:gasUsed", result.gasUsed.toNumber());
    };
    const { EtherscanToken, OpenSeaPath } = getAddresses(
      props.network,
      props.tokenAddress
    );
    return {
      chainId,
      mint,
      tokens,
      EtherscanToken,
      OpenSeaPath,
      tokenName: "ERC721",
      isConnected,
      account: store.state.account,
      totalBalance,
    };
  },
});
</script>

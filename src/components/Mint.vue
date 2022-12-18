<template>
  <div>
    <div v-if="nextImage">
      <img :src="nextImage" class="mr-1 mb-1 inline-block w-96" />
      <p>Next Token Id: {{ `${totalSupply}` }}</p>
    </div>
    <p>Available: {{ `${mintLimit - totalSupply}/${mintLimit}` }}</p>
    <NetworkGate :expectedNetwork="chainId">
      <p>Wallet: {{ wallet }}</p>
      <p>Network: {{ network }}</p>
      <p v-if="totalBalance > 0">
        You have {{ totalBalance }} whitelist token(s).
      </p>
      <div v-if="totalSupply < mintLimit">
        <div v-if="restricted && totalBalance == 0" class="text-yellow-500">
          Minting is available only to
          <a href="/#series" class="underline">{{ restricted }}</a> holders at
          this moment. Please wait for the announcement from @nounsfes.
        </div>
        <div v-else-if="limit && limit <= balanceOf" class="text-yellow-500">
          The maximum number of tokens you can mint is {{ limit }}.
        </div>
        <div v-else>
          <p>Price: {{ mintPriceString }} ETH</p>
          <p v-if="isMinting" class="mt-4 mb-4 bg-slate-200 pl-4">
            Processing...
          </p>
          <button
            v-else
            @click="mint"
            class="mt-2 inline-block rounded bg-green-600 px-6 py-2.5 leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-green-700 hover:shadow-lg focus:bg-green-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-green-800 active:shadow-lg"
          >
            {{ $t("mint.mint") }}
          </button>
        </div>
      </div>
      <div v-else>
        <div v-if="mintLimit == 0">
          <p>...</p>
        </div>
        <div v-else>
          <button
            disabled
            class="mt-2 inline-block rounded bg-red-600 px-6 py-2.5 leading-tight text-white shadow-md"
          >
            Sold Out
          </button>
        </div>
      </div>
    </NetworkGate>
    <div v-if="tokens.length > 0" class="mt-4">
      <p>Recently minted NFTs</p>
      <span v-for="token in tokens" :key="token.tokenId">
        <a :href="`${OpenSeaPath}/${token.tokenId}`" target="_blank">
          <img :src="token.image" class="mr-1 mb-1 inline-block w-32" />
        </a>
      </span>
    </div>
    <References :EtherscanToken="EtherscanToken" :TokenName="tokenName" />
  </div>
</template>

<script lang="ts">
import { defineComponent, computed, ref, watch } from "vue";
import { useStore } from "vuex";
import { useRoute } from "vue-router";
import { BigNumber } from "ethers";
import { ChainIdMap, displayAddress } from "@/utils/MetaMask";
import NetworkGate from "@/components/NetworkGate.vue";
import { getAddresses, getProvider, decodeTokenData, getSvgHelper, getTokenGate, getContractRO } from "@/utils/const";
import { getBalanceFromContractRO, getMintPriceForFromContractRO, getTotalSupplyFromContractRO, getMintLimitFromContractRO, getDebugTokenURI }  from "@/utils/const";
import References from "@/components/References.vue";
import { addresses } from "@/utils/addresses";
import { weiToEther } from "@/utils/currency";
import { svgImageFromSvgPart, sampleColors } from "@/models/point";

console.log("*** addresses", addresses);

interface Token {
  tokenId: number;
  image: string;
}

export default defineComponent({
  props: [
    "network",
    "tokenAddress",
    "tokenGated",
    "tokenGateAddress",
    "restricted",
    "limit",
    "assetProvider",
  ],
  emits: ["minted"],
  components: {
    NetworkGate,
    References,
  },
  setup(props, context) {
    const route = useRoute();
    const store = useStore();

    const totalBalance = ref<number>(0);
    const totalSupply = ref<number>(0);
    const balanceOf = ref<number>(0);
    const mintLimit = ref<number>(0);
    const mintPrice = ref<BigNumber>(BigNumber.from(0));
    const mintPriceString = computed(() => weiToEther(mintPrice.value));
    const isMinting = ref<boolean>(false);
    const nextImage = ref<string | null>(null);

    const affiliateId =
      typeof route.query.ref == "string" ? parseInt(route.query.ref) || 0 : 0;
    
    const alchemyKey = process.env.VUE_APP_ALCHEMY_API_KEY;
    const provider = getProvider(props.network, alchemyKey);

    const contractRO = getContractRO(props.tokenAddress, provider);

    const checkTokenGate = async () => {
      console.log("### calling totalBalanceOf");
      if (props.tokenGated) {
        const tokenGate = getTokenGate(props.tokenGateAddress, provider);
        const [result] = await tokenGate.functions.balanceOf(
          store.state.account
        );
        totalBalance.value = result.toNumber();
      }
      balanceOf.value = await getBalanceFromContractRO(contractRO, store.state.account);
      mintPrice.value = await getMintPriceForFromContractRO(contractRO, store.state.account);
      console.log("*** checkTokenGate", weiToEther(mintPrice.value));
    };

    const account = computed(() => store.state.account);
    watch(account, (v) => {
      if (v) {
        checkTokenGate();
      }
    });
    const wallet = computed(() => displayAddress(account.value));

    const providerAddress =
      addresses[props.assetProvider || "dotNouns"][props.network];

    const tokens = ref<Token[]>([]);
    const fetchTokens = async () => {
      const svgHelper = getSvgHelper(props.network, provider);
      totalSupply.value = await getTotalSupplyFromContractRO(contractRO);
      mintLimit.value = await getMintLimitFromContractRO(contractRO);
      console.log("totalSupply/mintLimit", totalSupply.value, mintLimit.value);
      if (totalSupply.value < mintLimit.value) {
        const [svgPart, tag, gas] = await svgHelper.functions.generateSVGPart(
          providerAddress,
          totalSupply.value
        );
        nextImage.value = svgImageFromSvgPart(svgPart, tag, "");
      } else {
        nextImage.value = null;
      }
      tokens.value = [];
      for (let tokenId = Math.max(0, totalSupply.value - 4); tokenId < totalSupply.value; tokenId++) {
        const { tokenURI, gas} = await getDebugTokenURI(contractRO, tokenId);
        console.log("gas", tokenId, gas);
        const { json } = decodeTokenData(tokenURI);
        tokens.value.push({ tokenId, image: json.image });
      }
    };
    fetchTokens();
    const once = async () => {
      /*
      const [value] = await contractRO.functions.tokensPerAsset();
      console.log("tokensPerAsset", value.toNumber());
      tokensPerAsset.value = value;
      */
    };
    once();

    provider.once("block", () => {
      contractRO.on(
        contractRO.filters.Transfer(),
        async (from, to, tokenId) => {
          console.log("*** event.Transfer calling fetchTokens");
          fetchTokens();
          context.emit("minted");
        }
      );
    });

    const chainId = ChainIdMap[props.network];
    const networkContext = computed(() => {
      const signer = store.getters.getSigner(chainId);
      if (signer) {
        const contract = getContractRO(props.tokenAddress, signer);
        return { provider, signer, contract };
      }
      return null;
    });
    const mint = async () => {
      if (networkContext.value == null) {
        return;
      }
      const { contract } = networkContext.value;
      console.log("*** minting", weiToEther(mintPrice.value));
      isMinting.value = true;
      try {
      const txParams = { value: mintPrice.value };
        const tx = await contract.functions.mint(txParams);
        console.log("mint:tx");
        const result = await tx.wait();
        console.log("mint:gasUsed", result.gasUsed.toNumber());
        await checkTokenGate();
      } catch (e) {
        console.error(e);
      }
      isMinting.value = false;
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
      wallet,
      totalBalance,
      balanceOf,
      mintPriceString,
      isMinting,
      totalSupply,
      mintLimit,
      nextImage,
    };
  },
});
</script>

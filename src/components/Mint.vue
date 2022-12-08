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
          Minting is available only to "{{ restricted }}" NFT holders at this
          moment. Please wait for the announcement from @nounsfes.
        </div>
        <div v-else-if="limit && limit <= balanceOf" class="text-yellow-500">
          The maximum number of tokens you can mint is {{ limit }}.
        </div>
        <div v-else>
          <p>Price: {{ mintPriceString }}</p>
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
import { BigNumber, ethers } from "ethers";
import { ChainIdMap, displayAddress } from "../utils/MetaMask";
import NetworkGate from "@/components/NetworkGate.vue";
import { getAddresses } from "@/utils/const";
import References from "@/components/References.vue";
import { addresses } from "@/utils/addresses";
import { weiToEther } from "@/utils/currency";
import { svgImageFromSvgPart, sampleColors } from "@/models/point";

const ProviderTokenEx = {
  wabi: require("@/abis/ProviderToken.json"), // wrapped abi
};
const ITokenGate = {
  wabi: require("@/abis/ITokenGate.json"), // wrapped abi
};
const ISVGHelper = {
  wabi: require("@/abis/ISVGHelper.json"), // wrapped abi
};

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
    const mintPriceString = computed(
      () => `${weiToEther(mintPrice.value)} ETH`
    );
    const isMinting = ref<boolean>(false);
    const nextImage = ref<string | null>(null);
    const svgHelperAddress = addresses["svgHelper"][props.network];

    const checkTokenGate = async () => {
      console.log("### calling totalBalanceOf");
      if (props.tokenGated) {
        const [result] = await tokenGate.functions.balanceOf(
          store.state.account
        );
        totalBalance.value = result.toNumber();
      }
      const [balance] = await contractRO.functions.balanceOf(
        store.state.account
      );
      balanceOf.value = balance;

      const [value] = await contractRO.functions.mintPriceFor(
        store.state.account
      );
      mintPrice.value = value;
      console.log("*** checkTokenGate", weiToEther(mintPrice.value));
    };

    const account = computed(() => {
      if (store.state.account == null) {
        return null;
      }
      checkTokenGate();
      return store.state.account;
    });
    const wallet = computed(() => displayAddress(account.value));

    const chainId = ChainIdMap[props.network];
    const alchemyKey = process.env.VUE_APP_ALCHEMY_API_KEY;
    const provider =
      props.network == "localhost"
        ? new ethers.providers.JsonRpcProvider()
        : props.network == "mumbai"
        ? new ethers.providers.JsonRpcProvider(
            "https://matic-mumbai.chainstacklabs.com"
          )
        : alchemyKey
        ? new ethers.providers.AlchemyProvider(props.network, alchemyKey)
        : new ethers.providers.InfuraProvider(props.network);

    const contractRO = new ethers.Contract(
      props.tokenAddress,
      ProviderTokenEx.wabi.abi,
      provider
    );
    const tokenGate = new ethers.Contract(
      props.tokenGateAddress, //
      ITokenGate.wabi.abi,
      provider
    );
    const svgHelper = new ethers.Contract(
      svgHelperAddress,
      ISVGHelper.wabi.abi,
      provider
    );
    const providerAddress =
      addresses[props.assetProvider || "dotNouns"][props.network];

    const tokens = ref<Token[]>([]);
    const fetchTokens = async () => {
      const [supply] = await contractRO.functions.totalSupply();
      totalSupply.value = supply.toNumber();
      const [limit] = await contractRO.functions.mintLimit();
      mintLimit.value = limit.toNumber();
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
      const updatedTokens = [];
      for (var tokenId = Math.max(0, supply - 4); tokenId < supply; tokenId++) {
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
      console.log("*** minting", weiToEther(mintPrice.value));
      const txParams = { value: mintPrice.value };
      isMinting.value = true;
      try {
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

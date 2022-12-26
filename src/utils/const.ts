import { ref, computed } from "vue";
import { useStore } from "vuex";
import { ethers, BigNumber } from "ethers";
import { addresses } from "@/utils/addresses";
import { svgImageFromSvgPart } from "@/models/point";

interface Token {
  tokenId: number;
  image: string;
}

type Provider =
  | ethers.providers.JsonRpcProvider
  | ethers.providers.AlchemyProvider
  | ethers.providers.InfuraProvider;
type ProviderOrSigner = ethers.providers.Provider | ethers.Signer | undefined;

export const getAddresses = (network: string, contentAddress: string) => {
  const EtherscanBase = (() => {
    if (network == "rinkeby") {
      return "https://rinkeby.etherscan.io/address";
    } else if (network == "goerli") {
      return "https://goerli.etherscan.io/address";
    } else if (network == "mumbai") {
      return "https://mumbai.polygonscan.com/address";
    }
    return "https://etherscan.io/address";
  })();
  const OpenSeaBase = (() => {
    if (network == "rinkeby") {
      return "https://testnets.opensea.io/assets/rinkeby";
    } else if (network == "goerli") {
      return "https://testnets.opensea.io/assets/goerli";
    } else if (network == "mumbai") {
      return "https://testnets.opensea.io/assets/mumbai";
    }
    return "https://opensea.io/assets/ethereum";
  })();
  const EtherscanToken = `${EtherscanBase}/${contentAddress}`;
  const OpenSeaPath = `${OpenSeaBase}/${contentAddress}`;

  return {
    EtherscanBase,
    OpenSeaBase,
    EtherscanToken,
    OpenSeaPath,
  };
};
export const getProvider = (
  network: string,
  alchemyKey: string | undefined
) => {
  return network == "localhost"
    ? new ethers.providers.JsonRpcProvider()
    : network == "mumbai"
    ? new ethers.providers.JsonRpcProvider(
        "https://matic-mumbai.chainstacklabs.com"
      )
    : alchemyKey
    ? new ethers.providers.AlchemyProvider(network, alchemyKey)
    : new ethers.providers.InfuraProvider(network);
};

const decodeTokenData = (tokenURI: string) => {
  const data = tokenURI.substring(29); // HACK: hardcoded
  const decoded = Buffer.from(data, "base64");
  const json = JSON.parse(decoded.toString());
  const svgData = json.image.substring(26); // hardcoded
  const svg = Buffer.from(svgData, "base64").toString();

  return { json, svg };
};

const ISVGHelper = {
  wabi: require("@/abis/ISVGHelper.json"), // wrapped abi
};
const ITokenGate = {
  wabi: require("@/abis/ITokenGate.json"), // wrapped abi
};
const ProviderTokenEx = {
  wabi: require("@/abis/ProviderToken.json"), // wrapped abi
};
const ProviderSVGTokenEx = {
  wabi: require("@/abis/SVGTokenV1.json"), // wrapped abi
};
const ProviderMessageTokenEx = {
  wabi: require("@/abis/MessageToken.json"), // wrapped abi
};
const ProviderMessageStoreEx = {
  wabi: require("@/abis/MessageStoreV1.json"), // wrapped abi
};
const IAssetProvider = {
  wabi: require("@/abis/IAssetProvider.json"), // wrapped abi
};

export const getSvgHelper = (network: string, provider: ProviderOrSigner) => {
  const svgHelperAddress = addresses["svgHelper"][network];
  const svgHelper = new ethers.Contract(
    svgHelperAddress,
    ISVGHelper.wabi.abi,
    provider
  );
  return svgHelper;
};

const getTokenGate = (address: string, provider: ProviderOrSigner) => {
  const tokenGate = new ethers.Contract(address, ITokenGate.wabi.abi, provider);
  return tokenGate;
};

export const getAssetProvider = (
  assetProviderName: string,
  network: string,
  provider: ProviderOrSigner
) => {
  const providerAddress = addresses[assetProviderName][network];
  const assetProvider = new ethers.Contract(
    providerAddress,
    IAssetProvider.wabi.abi,
    provider
  );
  return assetProvider;
};

export const getTokenContract = (
  address: string,
  provider: ProviderOrSigner
): ethers.Contract => {
  const tokenContract = new ethers.Contract(
    address,
    ProviderTokenEx.wabi.abi,
    provider
  );
  return tokenContract;
};

export const getSVGTokenContract = (
  address: string,
  provider: ProviderOrSigner
): ethers.Contract => {
  const tokenContract = new ethers.Contract(
    address,
    ProviderSVGTokenEx.wabi.abi,
    provider
  );
  return tokenContract;
};

export const getMessageTokenContract = (
  address: string,
  provider: ProviderOrSigner
): ethers.Contract => {
  const tokenContract = new ethers.Contract(
    address,
    ProviderMessageTokenEx.wabi.abi,
    provider
  );
  return tokenContract;
};

export const getMessageStoreContract = (
  address: string,
  provider: ProviderOrSigner
): ethers.Contract => {
  const tokenContract = new ethers.Contract(
    address,
    ProviderMessageStoreEx.wabi.abi,
    provider
  );
  return tokenContract;
};

// Token Contract functions
const getBalanceFromTokenContract = async (
  tokenContract: ethers.Contract,
  account: string
) => {
  const [balance] = await tokenContract.functions.balanceOf(account);
  return balance;
};
const getMintPriceForFromTokenContract = async (
  tokenContract: ethers.Contract,
  account: string
) => {
  const [value] = await tokenContract.functions.mintPriceFor(account);
  return value;
};
const getTotalSupplyFromTokenContract = async (
  tokenContract: ethers.Contract
) => {
  const [supply] = await tokenContract.functions.totalSupply();
  return supply.toNumber();
};

const getMintLimitFromTokenContract = async (
  tokenContract: ethers.Contract
) => {
  const [limit] = await tokenContract.functions.mintLimit();
  return limit.toNumber();
};
const getDebugTokenURI = async (
  tokenContract: ethers.Contract,
  tokenId: number
) => {
  const [tokenURI, gas] = await tokenContract.functions.debugTokenURI(tokenId);
  return { tokenURI, gas: gas.toNumber() };
};

export const useFetchTokens = (
  network: string,
  assetProvider: string | undefined,
  provider: Provider,
  contractRO: ethers.Contract
) => {
  const totalSupply = ref<number>(0);
  const mintLimit = ref<number>(0);
  const nextImage = ref<string | null>(null);
  const tokens = ref<Token[]>([]);

  const fetchTokens = async () => {
    const svgHelper = getSvgHelper(network, provider);
    totalSupply.value = await getTotalSupplyFromTokenContract(contractRO);
    mintLimit.value = await getMintLimitFromTokenContract(contractRO);

    const providerAddress = addresses[assetProvider || "dotNouns"][network];

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
    for (
      let tokenId = Math.max(0, totalSupply.value - 4);
      tokenId < totalSupply.value;
      tokenId++
    ) {
      const { tokenURI, gas } = await getDebugTokenURI(contractRO, tokenId);
      console.log("gas", tokenId, gas);
      const { json } = decodeTokenData(tokenURI);
      tokens.value.push({ tokenId, image: json.image });
    }
  };
  return {
    totalSupply,
    mintLimit,
    nextImage,
    tokens,

    fetchTokens,
  };
};

export const useCheckTokenGate = (
  tokenGateAddress: string,
  tokenGated: boolean,
  provider: Provider,
  contractRO: ethers.Contract
) => {
  const totalBalance = ref<number>(0);
  const balanceOf = ref<number>(0);
  const mintPrice = ref<BigNumber>(BigNumber.from(0));

  const checkTokenGate = async (account: string) => {
    console.log("### calling totalBalanceOf");
    if (tokenGated) {
      const tokenGate = getTokenGate(tokenGateAddress, provider);
      const [result] = await tokenGate.functions.balanceOf(account);
      totalBalance.value = result.toNumber();
    }
    balanceOf.value = await getBalanceFromTokenContract(contractRO, account);
    mintPrice.value = await getMintPriceForFromTokenContract(
      contractRO,
      account
    );
  };
  return {
    totalBalance,
    balanceOf,
    mintPrice,

    checkTokenGate,
  };
};

export const _useNetworkContext = (
  chainId: string,
  tokenAddress: string,
  func: (address: string, provider: ProviderOrSigner) => ethers.Contract
) => {
  const store = useStore();

  const networkContext = computed(() => {
    const signer = store.getters.getSigner(chainId);
    console.log(signer, chainId);
    if (signer) {
      const contract = func(tokenAddress, signer);
      return { signer, contract };
    }
    return null;
  });

  return {
    networkContext,
  };
};

export const useTokenNetworkContext = (
  chainId: string,
  tokenAddress: string
) => {
  return _useNetworkContext(chainId, tokenAddress, getTokenContract);
};

export const useSVGTokenNetworkContext = (
  chainId: string,
  tokenAddress: string
) => {
  return _useNetworkContext(chainId, tokenAddress, getSVGTokenContract);
};

export const useMessageTokenNetworkContext = (
  chainId: string,
  tokenAddress: string
) => {
  return _useNetworkContext(chainId, tokenAddress, getMessageTokenContract);
};

export const useMessageStoreNetworkContext = (
  chainId: string,
  tokenAddress: string
) => {
  return _useNetworkContext(chainId, tokenAddress, getMessageStoreContract);
};

import { ethers } from "ethers";
import { addresses } from "@/utils/addresses";

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

export const decodeTokenData = (tokenURI: string) => {
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
const IAssetProvider = {
  wabi: require("@/abis/IAssetProvider.json"), // wrapped abi
};

export const getSvgHelper = (
  network: string,
  provider: ethers.providers.Provider | ethers.Signer | undefined
) => {
  const svgHelperAddress = addresses["svgHelper"][network];
  const svgHelper = new ethers.Contract(
    svgHelperAddress,
    ISVGHelper.wabi.abi,
    provider
  );
  return svgHelper;
};

export const getTokenGate = (
  address: string,
  provider: ethers.providers.Provider | ethers.Signer | undefined
) => {
  const tokenGate = new ethers.Contract(address, ITokenGate.wabi.abi, provider);
  return tokenGate;
};

export const getAssetProvider = (
  assetProviderName: string,
  network: string,
  provider: ethers.providers.Provider | ethers.Signer | undefined,
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
  provider: ethers.providers.Provider | ethers.Signer | undefined
) => {
  const tokenContract = new ethers.Contract(
    address,
    ProviderTokenEx.wabi.abi,
    provider
  );
  return tokenContract;
};

// Token Contract functions
export const getBalanceFromTokenContract = async (
  tokenContract: ethers.Contract,
  account: string
) => {
  const [balance] = await tokenContract.functions.balanceOf(account);
  return balance;
};
export const getMintPriceForFromTokenContract = async (
  tokenContract: ethers.Contract,
  account: string
) => {
  const [value] = await tokenContract.functions.mintPriceFor(account);
  return value;
};
export const getTotalSupplyFromTokenContract = async (
  tokenContract: ethers.Contract
) => {
  const [supply] = await tokenContract.functions.totalSupply();
  return supply.toNumber();
};

export const getMintLimitFromTokenContract = async (
  tokenContract: ethers.Contract
) => {
  const [limit] = await tokenContract.functions.mintLimit();
  return limit.toNumber();
};
export const getDebugTokenURI = async (
  tokenContract: ethers.Contract,
  tokenId: number
) => {
  const [tokenURI, gas] = await tokenContract.functions.debugTokenURI(tokenId);
  return { tokenURI, gas: gas.toNumber() };
};

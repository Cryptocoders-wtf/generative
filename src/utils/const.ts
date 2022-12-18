import { ethers } from "ethers";

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

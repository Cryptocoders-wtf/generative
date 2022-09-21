export const getAddresses = (
  network: string,
  storeAddress: string,
  contentAddress: string
) => {
  const EtherscanBase =
    network == "rinkeby"
      ? "https://rinkeby.etherscan.io/address"
      : "https://etherscan.io/address";
  const OpenSeaBase =
    network == "rinkeby"
      ? "https://testnets.opensea.io/assets/rinkeby"
      : "https://opensea.io/assets/ethereum";
  const EtherscanStore = `${EtherscanBase}/${storeAddress}`;
  const EtherscanToken = `${EtherscanBase}/${contentAddress}`;
  const OpenSeaPath = `${OpenSeaBase}/${contentAddress}`;

  return {
    EtherscanBase,
    OpenSeaBase,
    EtherscanStore,
    EtherscanToken,
    OpenSeaPath,
  };
};

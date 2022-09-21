import store from "../store";

export const requestAccount = async () => {
  const ethereum = store.state.ethereum;
  if (!ethereum) {
    return null;
  }
  console.log(ethereum.request);
  const accounts = await ethereum.request({ method: "eth_requestAccounts" });
  return accounts.length > 0 ? accounts[0] : null;
};

export const getAccount = async (): Promise<string | null> => {
  const ethereum = store.state.ethereum;
  if (!ethereum) {
    return null;
  }
  const accounts = await ethereum.request({ method: "eth_accounts" });
  return accounts.length > 0 ? accounts[0] : null;
};

// https://github.com/NoahZinsmeister/web3-react/blob/main/packages/types/src/index.ts
// per EIP-1193
export interface ProviderConnectInfo {
  readonly chainId: string;
}

export interface ProviderRpcError extends Error {
  message: string;
  code: number;
  data?: unknown;
}

export const ChainIds = {
  Mainnet: "0x1",
  RinkebyTestNet: "0x4",
  Goerli: "0x5",
  Polygon: "0x89",
  Localhost: "0x7a69", // not sure
};

export const initializeEthereum = () => {
  const setEthereum = () => {
    const ethereum = (window as any).ethereum;
    if (store.state.ethereum != ethereum) {
      store.commit("setEthereum", ethereum);
    }
  };
  const ethereum = (window as any).ethereum;
  if (ethereum) {
    setEthereum();
  } else {
    window.addEventListener(
      "ethereum#initialized",
      () => {
        setEthereum();
      },
      { once: true }
    );
    setTimeout(setEthereum, 30000); // 30 seconds in which nothing happens on android
  }
};

export const startMonitoringMetamask = () => {
  getAccount().then((value) => {
    console.log("Eth gotAccount", store.getters.displayAccount);
    store.commit("setAccount", value);
    const ethereum = store.state.ethereum;
    ethereum
      .request({
        method: "eth_chainId",
      })
      .then((chainId: string) => {
        store.commit("setChainId", chainId);
      });
  });
  if (store.getters.hasMetaMask) {
    const ethereum = store.state.ethereum;
    ethereum.on("accountsChanged", (accounts: string[]) => {
      //console.log("accountsChanged", accounts.length);
      if (accounts.length == 0) {
        store.commit("setAccount", null);
      } else {
        console.log("Eth acountsChanged", store.getters.displayAccount);
        store.commit("setAccount", accounts[0]);
      }
    });
    ethereum.on("connect", (info: ProviderConnectInfo): void => {
      console.log("Eth connect", info, store.getters.displayAccount);
      store.commit("setChainId", info.chainId);
    });
    ethereum.on("disconnect", (info: ProviderRpcError): void => {
      console.log("Eth disconnect", info);
    });
    ethereum.on("chainChanged", (chainId: string) => {
      store.commit("setChainId", chainId);
    });
  }
};

export const switchNetwork = async (chainId: string) => {
  const ethereum = store.state.ethereum;
  try {
    await ethereum.request({
      method: "wallet_switchEthereumChain",
      params: [{ chainId }],
    });
  } catch (e) {
    console.log(e);
  }
};

export const displayAddress = (address: string) => {
  return address.substring(0, 6) + "..." + address.substring(38);
};

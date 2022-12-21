import { addresses as mainnet } from "./addresses/addresses_mainnet";
import { addresses as goerli } from "./addresses/addresses_goerli";
import { kamon_addresses as kamon_mainnet } from "./addresses/addresses_kamon_mainnet";
import { kamon_addresses as kamon_goerli } from "./addresses/addresses_kamon_goerli";
import { token_addresses as flag_mainnet } from "./addresses/addresses_flag_mainnet";
import { token_addresses as flag_goerli } from "./addresses/addresses_flag_goerli";
import { Addresses, WhiteList } from "@/utils/addresses";

export const addresses: Addresses = {
  assetStore: {
    goerli: goerli.storeAddress,
    mainnet: mainnet.storeAddress,
  },
  material: {
    goerli: goerli.tokenAddress,
    mainnet: mainnet.tokenAddress,
  },
  kamon: {
    goerli: kamon_goerli.kamonAddress,
    mainnet: kamon_mainnet.kamonAddress,
  },
  flag: {
    goerli: flag_goerli.emojiFlagAddress,
    mainnet: flag_mainnet.emojiFlagAddress,
  },
};

export const whitelistTokens: WhiteList = {
  goerli: [
    goerli.tokenAddress,
    kamon_goerli.kamonAddress,
    flag_goerli.emojiFlagAddress,
  ],
  mainnet: [
    mainnet.tokenAddress,
    kamon_mainnet.kamonAddress,
    flag_mainnet.emojiFlagAddress,
  ],
  localhost: [],
};

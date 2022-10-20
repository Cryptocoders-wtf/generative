import { addresses as splatter_goerli } from "./addresses/splatter_goerli";
import { addresses as splatter_localhost } from "./addresses/splatter_localhost";
import { addresses as splatter_mainnet } from "./addresses/splatter_mainnet";
import { addresses as snow_goerli } from "./addresses/snow_goerli";
import { addresses as snow_localhost } from "./addresses/snow_localhost";
import { addresses as tokenGate_goerli } from "./addresses/tokenGate_goerli";
import { addresses as tokenGate_localhost } from "./addresses/tokenGate_localhost";
import { addresses as tokenGate_mainnet } from "./addresses/tokenGate_mainnet";
import { addresses as sample_goerli } from "./addresses/sample_goerli";
import { addresses as sample_localhost } from "./addresses/sample_localhost";
import { addresses as nouns_goerli } from "./addresses/nouns_goerli";
import { addresses as store_goerli } from "./addresses/addresses_goerli";
import { addresses as store_localhost } from "./addresses/addresses_localhost";
import { addresses as store_mainnet } from "./addresses/addresses_mainnet";
import { addresses as bitcoin_goerli } from "./addresses/bitcoin_goerli";
import { addresses as bitcoin_localhost } from "./addresses/bitcoin_localhost";

export const addresses: any = {
  svgHelper: {
    goerli: splatter_goerli.svgHelperAddress,
    localhost: splatter_localhost.svgHelperAddress,
    mainnet: splatter_mainnet.svgHelperAddress,
  },
  splatter: {
    goerli: splatter_goerli.splatterAddress,
    localhost: splatter_localhost.splatterAddress,
    mainnet: splatter_mainnet.splatterAddress,
  },
  splatterArt: {
    goerli: splatter_goerli.splatterArtAddress,
    localhost: splatter_localhost.splatterArtAddress,
    mainnet: splatter_mainnet.splatterArtAddress,
  },
  splatterToken: {
    goerli: splatter_goerli.splatterToken,
    mainnet: splatter_mainnet.splatterToken,
  },
  snow: {
    goerli: snow_goerli.snowAddress,
    localhost: snow_localhost.snowAddress,
  },
  snowArt: {
    goerli: snow_goerli.snowArtAddress,
    localhost: snow_localhost.snowArtAddress,
  },
  tokenGate: {
    goerli: tokenGate_goerli.tokenGate,
    localhost: tokenGate_localhost.tokenGate,
    mainnet: tokenGate_mainnet.tokenGate,
  },
  nouns: {
    goerli: nouns_goerli.providerAddress,
  },
  nounsArt: {
    goerli: nouns_goerli.nounsArt,
  },
  sample: {
    goerli: sample_goerli.providerAddress,
    localhost: sample_localhost.providerAddress,
  },
  assetStore: {
    goerli: store_goerli.storeAddress,
    mainnet: store_mainnet.storeAddress,
    localhost: store_localhost.storeAddress,
  },
  bitcoin: {
    goerli: bitcoin_goerli.bitcoinArtProvider,
    localhost: bitcoin_localhost.bitcoinArtProvider,
  },
};

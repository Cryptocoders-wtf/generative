import { addresses as splatter_goerli } from "./addresses/splatter_goerli";
import { addresses as splatter_localhost } from "./addresses/splatter_localhost";
import { addresses as snow_goerli } from "./addresses/snow_goerli";
import { addresses as snow_localhost } from "./addresses/snow_localhost";
import { addresses as tokenGate_goerli } from "./addresses/tokenGate_goerli";
import { addresses as tokenGate_localhost } from "./addresses/tokenGate_localhost";
import { addresses as tokenGate_mainet } from "./addresses/tokenGate_mainnet";
import { addresses as sample_goerli } from "./addresses/sample_goerli";
import { addresses as sample_localhost } from "./addresses/sample_localhost";
import { addresses as nouns_goerli } from "./addresses/nouns_goerli";

export const addresses: any = {
  svgHelper: {
    goerli: splatter_goerli.svgHelperAddress,
    localhost: splatter_localhost.svgHelperAddress,
  },
  splatter: {
    goerli: splatter_goerli.splatterAddress,
    localhost: splatter_localhost.splatterAddress,
  },
  splatterArt: {
    goerli: splatter_goerli.splatterArtAddress,
    localhost: splatter_localhost.splatterArtAddress,
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
    mainnet: tokenGate_mainet.tokenGate,
  },
  nouns: {
    goerli: nouns_goerli.providerAddress,
    localhost: nouns_goerli.providerAddress, // hack
  },
  sample: {
    goerli: sample_goerli.providerAddress,
    localhost: sample_localhost.providerAddress,
  },
};

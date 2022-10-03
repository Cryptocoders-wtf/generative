import { addresses as splatter_goerli } from "./addresses/splatter_goerli";
import { addresses as splatter_localhost } from "./addresses/splatter_localhost";

export const addresses: any = {
  splatter: {
    goerli: splatter_goerli.splatterAddress,
    localhost: splatter_localhost.splatterAddress,
  },
  splatterArt: {
    goerli: splatter_goerli.splatterArtAddress,
    localhost: splatter_localhost.splatterArtAddress,
  },
};

import { addresses as splatter_goerli } from "./addresses/splatter_goerli";
import { addresses as splatter_rinkeby } from "./addresses/splatter_rinkeby";

export const addresses: any = {
  splatter: {
    goerli: splatter_goerli.splatterAddress,
    rinkeby: splatter_rinkeby.splatterAddress,
  },
  splatterArt: {
    goerli: splatter_goerli.splatterArtAddress,
    rinkeby: splatter_rinkeby.splatterArtAddress,
  },
};

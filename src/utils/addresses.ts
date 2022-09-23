import { addresses as goerli_address } from "./addresses/splatter_goerli";
import { addresses as rinkeby_address } from "./addresses/splatter_rinkeby";

export const addresses: any = {
  splatter: {
    goerli: goerli_address.splatterAddress,
    rinkeby: rinkeby_address.splatterAddress,
  },
  splatterArt: {
    goerli: goerli_address.splatterArtAddress,
    rinkeby: rinkeby_address.splatterArtAddress,
  },
};

import { addresses as splatter_goerli } from "./addresses/splatter_goerli";
import { addresses as splatter_localhost } from "./addresses/splatter_localhost";
import { addresses as splatter_mainnet } from "./addresses/splatter_mainnet";
import { addresses as splatter_mumbai } from "./addresses/splatter_mumbai";
import { addresses as snow_goerli } from "./addresses/snow_goerli";
import { addresses as snow_localhost } from "./addresses/snow_localhost";
import { addresses as tokenGate_goerli } from "./addresses/tokenGate_goerli";
import { addresses as tokenGate_localhost } from "./addresses/tokenGate_localhost";
import { addresses as tokenGate_mainnet } from "./addresses/tokenGate_mainnet";
import { addresses as tokenGate_mumbai } from "./addresses/tokenGate_mumbai";
import { addresses as sample_goerli } from "./addresses/sample_goerli";
import { addresses as sample_localhost } from "./addresses/sample_localhost";
import { addresses as nouns_goerli } from "./addresses/nouns_goerli";
import { addresses as nouns_localhost } from "./addresses/nouns_localhost";
import { addresses as nouns_mainnet } from "./addresses/nouns_mainnet";
import { addresses as nounsV2_goerli } from "./addresses/nounsV2_goerli";
import { addresses as nounsV2_localhost } from "./addresses/nounsV2_localhost";
import { addresses as nounsV2_mainnet } from "./addresses/nounsV2_mainnet";
import { addresses as store_goerli } from "./addresses/addresses_goerli";
import { addresses as store_localhost } from "./addresses/addresses_localhost";
import { addresses as store_mainnet } from "./addresses/addresses_mainnet";
import { addresses as bitcoin_goerli } from "./addresses/bitcoin_goerli";
import { addresses as bitcoin_localhost } from "./addresses/bitcoin_localhost";
import { addresses as bitcoin_mainnet } from "./addresses/bitcoin_mainnet";
import { addresses as reddit_goerli } from "./addresses/reddit_goerli";
import { addresses as dotNouns_goerli } from "./addresses/dotNouns_goerli";
import { addresses as dotNouns_localhost } from "./addresses/dotNouns_localhost";
import { addresses as dotNouns_mainnet } from "./addresses/dotNouns_mainnet";
import { addresses as dotNounsToken_localhost } from "./addresses/dotNounsToken_localhost";
import { addresses as dotNounsToken_goerli } from "./addresses/dotNounsToken_goerli";
import { addresses as dotNounsToken_mainnet } from "./addresses/dotNounsToken_mainnet";
import { addresses as paperNouns_goerli } from "./addresses/paperNouns_goerli";
import { addresses as paperNouns_localhost } from "./addresses/paperNouns_localhost";
import { addresses as paperNouns_mainnet } from "./addresses/paperNouns_mainnet";
import { addresses as lilnouns_goerli } from "./addresses/lilnouns_goerli";
import { addresses as circles_localhost } from "./addresses/circles_localhost";
import { addresses as star_localhost } from "./addresses/star_localhost";
import { addresses as star_goerli } from "./addresses/star_goerli";
import { addresses as star_mumbai } from "./addresses/star_mumbai";
import { addresses as pnouns_goerli } from "./addresses/pnouns_goerli";
import { addresses as pnouns_localhost } from "./addresses/pnouns_localhost";
import { addresses as color_mumbai } from "./addresses/colors_mumbai";
import { addresses as color_localhost } from "./addresses/colors_localhost";
import { addresses as londrina_solid_localhost } from "./addresses/londrina_solid_localhost";
import { addresses as londrina_solid_mumbai } from "./addresses/londrina_solid_mumbai";
import { addresses as londrina_solid_goerli } from "./addresses/londrina_solid_goerli";
import { addresses as londrina_solid_mainnet } from "./addresses/londrina_solid_mainnet";
import { addresses as matrix_mumbai } from "./addresses/matrix_mumbai";
import { addresses as matrix_goerli } from "./addresses/matrix_goerli";
import { addresses as matrix_localhost } from "./addresses/matrix_localhost";
import { addresses as matrix_mainet } from "./addresses/matrix_mainnet";
import { addresses as alphabet_mumbai } from "./addresses/alphabet_mumbai";
import { addresses as alphabet_localhost } from "./addresses/alphabet_localhost";
import { addresses as alphabet_mainnet } from "./addresses/alphabet_mainnet";
import { addresses as alphabet_goerli } from "./addresses/alphabet_goerli";
import { addresses as alphatoken_mumbai } from "./addresses/alphatoken_mumbai";
import { addresses as alphatoken_localhost } from "./addresses/alphatoken_localhost";
import { addresses as alphatoken_goerli } from "./addresses/alphatoken_goerli";
import { addresses as alphatoken_mainnet } from "./addresses/alphatoken_mainnet";
import { addresses as dynamic_mumbai } from "./addresses/dynamic_mumbai";
import { addresses as dynamic_mainnet } from "./addresses/dynamic_mainnet";
import { addresses as dynamic_goerli } from "./addresses/dynamic_goerli";
import { addresses as dynamic_localhost } from "./addresses/dynamic_localhost";

export const addresses: any = {
  svgHelper: {
    goerli: splatter_goerli.svgHelperAddress,
    mumbai: color_mumbai.svgHelper,
    localhost: splatter_mainnet.svgHelperAddress, // deployed
    mainnet: splatter_mainnet.svgHelperAddress,
  },
  splatter: {
    goerli: splatter_goerli.splatterAddress,
    localhost: splatter_localhost.splatterAddress,
    mainnet: splatter_mainnet.splatterAddress,
    mumbai: splatter_mumbai.splatterAddress,
  },
  splatterArt: {
    goerli: splatter_goerli.splatterArtAddress,
    localhost: splatter_localhost.splatterArtAddress,
    mainnet: splatter_mainnet.splatterArtAddress,
    mumbai: splatter_mumbai.splatterArtAddress,
  },
  splatterToken: {
    goerli: splatter_goerli.splatterToken,
    mainnet: splatter_mainnet.splatterToken,
    localhost: splatter_localhost.splatterToken,
    mumbai: splatter_mumbai.splatterToken,
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
    mumbai: tokenGate_mumbai.tokenGate,
  },
  nouns: {
    goerli: nouns_goerli.providerAddress,
    localhost: nouns_localhost.providerAddress,
    mainnet: nouns_mainnet.providerAddress,
  },
  nounsV2: {
    goerli: nounsV2_goerli.providerAddress,
    localhost: nounsV2_localhost.providerAddress,
    mainnet: nounsV2_mainnet.providerAddress,
  },
  /*
  nounsArt: {
    goerli: nouns_goerli.nounsArt,
  },
  */
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
    mainnet: bitcoin_mainnet.bitcoinArtProvider,
  },
  bitcoinToken: {
    goerli: bitcoin_goerli.bitcoinToken,
    // localhost: bitcoin_localhost.bitcoinToken,
    mainnet: bitcoin_mainnet.bitcoinToken,
  },
  assetStoreProvider: {
    goerli: bitcoin_goerli.assetStoreProvider,
    localhost: bitcoin_localhost.assetStoreProvider,
    mainnet: bitcoin_mainnet.assetStoreProvider,
  },
  coinProvider: {
    goerli: bitcoin_goerli.coinProvider,
    localhost: bitcoin_localhost.coinProvider,
    mainnet: bitcoin_mainnet.coinProvider,
  },
  colorSchemes: {
    goerli: bitcoin_goerli.colorSchemes,
    //localhost: bitcoin_localhost.colorSchemes,
    mainnet: bitcoin_mainnet.colorSchemes,
    localhost: color_localhost.colorSchemes,
    mumbai: color_mumbai.colorSchemes,
  },
  reddit: {
    goerli: reddit_goerli.redditArtProvider,
    mainnet: reddit_goerli.redditArtProvider, // HACK
  },
  redditToken: {
    goerli: reddit_goerli.redditToken,
    mainnet: reddit_goerli.redditToken, // HACK
  },
  dotNouns: {
    goerli: dotNouns_goerli.dotNounsArt,
    localhost: dotNouns_localhost.dotNounsArt,
    mainnet: dotNouns_mainnet.dotNounsArt,
  },
  dotNounsToken: {
    localhost: dotNounsToken_localhost.dotNounsToken,
    goerli: dotNounsToken_goerli.dotNounsToken,
    mainnet: dotNounsToken_mainnet.dotNounsToken,
  },
  paperNouns: {
    localhost: paperNouns_localhost.dotNounsArt,
    goerli: paperNouns_goerli.dotNounsArt,
    mainnet: paperNouns_mainnet.dotNounsArt,
  },
  lilnouns: {
    goerli: lilnouns_goerli.providerAddress,
  },
  dotlilArt: {
    goerli: lilnouns_goerli.dotNounsArt,
  },
  circles: {
    localhost: circles_localhost.contractArt,
  },
  matrixGenerator: {
    localhost: circles_localhost.matrixGenerator,
  },
  circleStencil: {
    localhost: circles_localhost.contractCircleStencil,
  },
  stencil: {
    localhost: circles_localhost.contractStencil,
  },
  glassesStencil: {
    localhost: circles_localhost.contractGlassesStencil,
  },
  star: {
    localhost: star_localhost.starAddress,
    goerli: star_goerli.starAddress,
    mumbai: star_mumbai.starAddress,
  },
  pnouns: {
    goerli: pnouns_goerli.pnouns,
    localhost: pnouns_localhost.pnouns,
  },
  londrina_solid: {
    mumbai: londrina_solid_mumbai.font,
    localhost: londrina_solid_localhost.font,
    goerli: londrina_solid_goerli.font,
    mainnet: londrina_solid_mainnet.font,
  },
  matrix: {
    localhost: matrix_localhost.matrix,
    mumbai: matrix_mumbai.matrix,
    goerli: matrix_goerli.matrix,
    mainnet: matrix_mainet.matrix,
  },
  alphabet: {
    localhost: alphabet_localhost.alphabetProvider,
    mumbai: alphabet_mumbai.alphabetProvider,
    mainnet: alphabet_mainnet.alphabetProvider,
    goerli: alphabet_goerli.alphabetProvider,
  },
  alphabetToken: {
    localhost: alphatoken_localhost.alphatoken,
    mumbai: alphatoken_mumbai.alphatoken,
    goerli: alphatoken_goerli.alphatoken,
    mainnet: alphatoken_mainnet.alphatoken,
  },
  dynamic: {
    mumbai: dynamic_mumbai.tokenGate,
    localhost: dynamic_mainnet.tokenGate, // already deployed on mainnet!
    mainnet: dynamic_mainnet.tokenGate,
    goerli: dynamic_goerli.tokenGate,
  },
};

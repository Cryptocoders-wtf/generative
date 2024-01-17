import * as dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-etherscan";

dotenv.config();

const getUrl = () => {
  return process.env.INFURA_API_KEY ?
    "https://rinkeby.infura.io/v3/" + process.env.INFURA_API_KEY : 
    "https://eth-rinkeby.alchemyapi.io/v2/" + process.env.ALCHEMY_API_KEY
};

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        details: {
          yulDetails: {
            optimizerSteps: "u",
          },
        },
      },
    }
  },
  defaultNetwork: "localhost",
  networks: {
    polygon: {
      url: "https://polygon-mainnet.g.alchemy.com/v2/" + process.env.ALCHEMY_API_KEY,
      // gasMultiplier: 1.7,
      gasPrice: 110_000_000_000, // 100 Gwei in wei
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    mumbai: {
      // url: "https://rpc-mumbai.maticvigil.com",
      url: "https://polygon-mumbai.g.alchemy.com/v2/" + process.env.ALCHEMY_API_KEY,
      gasMultiplier: 1.3,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    rinkeby: {
      url: getUrl(),
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/" + process.env.ALCHEMY_API_KEY2,
      // url: "https://goerli.infura.io/v3/" + process.env.INFURA_API_KEY,
      gasMultiplier: 1.7,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    mainnet: {
      url: "https://eth-mainnet.g.alchemy.com/v2/" + process.env.ALCHEMY_API_KEY,
      gasMultiplier: 1.1,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    }
  },
  // https://stackoverflow.com/questions/73618935/hardhat-verification-for-polygon-mumbai-fails
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
    // customChains: [
    //   {
    //     network: "mumbai",
    //     chainId: 80001,
    //     urls: {
    //       apiURL: "https://api-testnet.polygonscan.com",
    //       browserURL: "https://mumbai.polygonscan.com"
    //     }
    //   }
    // ]
  },
};

export default config;

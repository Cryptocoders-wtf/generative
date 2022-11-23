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
  solidity: "0.8.17",
  defaultNetwork: "localhost",
  networks: {
    mumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    rinkeby: {
      url: getUrl(),
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    goerli: {
      url2: "https://eth-goerli.g.alchemy.com/v2/" + process.env.ALCHEMY_API_KEY2,
      url: "https://goerli.infura.io/v3/" + process.env.INFURA_API_KEY,
      gasMultiplier: 1.4,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    mainnet: {
      url: "https://eth-mainnet.alchemyapi.io/v2/" + process.env.ALCHEMY_API_KEY,
      gasMultiplier: 1.2,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    }
  },
  // https://stackoverflow.com/questions/73618935/hardhat-verification-for-polygon-mumbai-fails
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
    customChains: [
      {
        network: "mumbai",
        chainId: 80001,
        urls: {
          apiURL: "https://api-testnet.polygonscan.com",
          browserURL: "https://mumbai.polygonscan.com"
        }
      }
    ]
  },
};

export default config;

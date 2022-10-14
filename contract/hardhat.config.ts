import * as dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

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
    rinkeby: {
      url: getUrl(),
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/" + process.env.ALCHEMY_API_KEY,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    mainnet: {
      url: "https://eth-mainnet.alchemyapi.io/v2/" + process.env.ALCHEMY_API_KEY,
      gasMultiplier: 1.2,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    }
  }
};

export default config;

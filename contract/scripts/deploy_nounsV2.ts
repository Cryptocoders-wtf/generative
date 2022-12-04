import { ethers, network } from "hardhat";
import { writeFile } from "fs";

import addresses from '@nouns/sdk/dist/contract/addresses.json';

const nounsTokenAddress:string = (network.name == "goerli") ?
  addresses[5].nounsToken: addresses[1].nounsToken;

console.log("nounsToken", nounsTokenAddress);

async function main() {
  const factoryNounsToken = await ethers.getContractFactory("NounsToken");
  const nounsToken = factoryNounsToken.attach(nounsTokenAddress);
  const [nounsDescriptor] = await nounsToken.functions.descriptor();
  console.log("nounsDescriptor", nounsDescriptor);

  const factory = await ethers.getContractFactory("NounsAssetProviderV2");
  const contractProvider = await factory.deploy(nounsTokenAddress, nounsDescriptor);
  await contractProvider.deployed();
  console.log(`      provider="${contractProvider.address}"`);

  const addresses = `export const addresses = {\n`
    + `  providerAddress:"${contractProvider.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/nouns_${network.name}.ts`, addresses, ()=>{});

  console.log(`npx hardhat verify ${contractProvider.address} ${nounsTokenAddress} ${nounsDescriptor} --network ${network.name}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

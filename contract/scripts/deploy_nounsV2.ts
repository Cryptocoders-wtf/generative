import { ethers, network } from "hardhat";
import { writeFile } from "fs";

import addresses from '@nouns/sdk/dist/contract/addresses.json';

const nounsDescriptor:string = (network.name == "goerli") ?
  addresses[5].nounsDescriptor: "0x6229c811D04501523C6058bfAAc29c91bb586268"; // addresses[1].nounsDescriptor;
const nounsToken:string = (network.name == "goerli") ?
  addresses[5].nounsToken: addresses[1].nounsToken;

console.log("nounsDescriptor", nounsDescriptor);

async function main() {
  const factory = await ethers.getContractFactory("NounsAssetProviderV2");
  const contractProvider = await factory.deploy(nounsToken, nounsDescriptor);
  await contractProvider.deployed();
  console.log(`      provider="${contractProvider.address}"`);

  const addresses = `export const addresses = {\n`
    + `  providerAddress:"${contractProvider.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/nouns_${network.name}.ts`, addresses, ()=>{});

  console.log(`npx hardhat verify ${contractProvider.address} ${nounsToken} ${nounsDescriptor} --network ${network.name}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

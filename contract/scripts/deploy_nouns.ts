import { ethers, network } from "hardhat";
import { writeFile } from "fs";

import addresses from '@nouns/sdk/dist/contract/addresses.json';

const nounsDescriptorAddress:string = (network.name == "goerli") ?
  addresses[5].nounsDescriptor: addresses[1].nounsDescriptor;
const nounsTokenAddress:string = (network.name == "goerli") ?
  addresses[5].nounsToken: addresses[1].nounsToken;

console.log("nounsDescriptor", nounsDescriptorAddress);
console.log("nounsToken", nounsTokenAddress);

async function main() {
  const nounsToken = await ethers.getContractAt("NounsToken", nounsTokenAddress);
  const nounsDescriptor = await ethers.getContractAt("INounsDescriptor", nounsDescriptorAddress);

  const seeds0 = await nounsToken.functions.seeds(0);
  console.log("seeds0", seeds0);
  const seeds = {
    background: seeds0.background,
    body: seeds0.body,
    accessory: seeds0.accessory,
    head: seeds0.head,
    glasses: seeds0.glasses
  };
  console.log("seeds", seeds);
  const svg = await nounsDescriptor.generateSVGImage(seeds);
  console.log(svg);

  const factory = await ethers.getContractFactory("NounsAssetProvider");
  const contractProvider = await factory.deploy(nounsTokenAddress, nounsDescriptorAddress);
  await contractProvider.deployed();
  console.log(`      provider="${contractProvider.address}"`);

  const addresses = `export const addresses = {\n`
    + `  providerAddress:"${contractProvider.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/nouns_${network.name}.ts`, addresses, ()=>{});

  console.log(`npx hardhat verify ${contractProvider.address} ${nounsTokenAddress} ${nounsDescriptorAddress} --network ${network.name}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

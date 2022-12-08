import { ethers, network } from "hardhat";
import { writeFile } from "fs";

import addresses from '@nouns/sdk/dist/contract/addresses.json';

const nounsTokenAddress:string = (network.name == "goerli") ?
  addresses[5].nounsToken: addresses[1].nounsToken;

console.log("nounsToken", nounsTokenAddress);

async function main() {
  const factoryNounsToken = await ethers.getContractFactory("NounsToken");
  const nounsToken = factoryNounsToken.attach(nounsTokenAddress);

  /*
  const [nounsDescriptorAddress] = await nounsToken.functions.descriptor();
  console.log("nounsDescriptor", nounsDescriptorAddress);
  const nounsDescriptor = await ethers.getContractAt("INounsDescriptor", nounsDescriptorAddress);
  */
  const seeds = await nounsToken.functions.seeds(505);
  console.log("seeds", seeds);
  // const svg = await nounsDescriptor.generateSVGImage(seeds);
  // console.log(svg);

  const factory = await ethers.getContractFactory("NounsAssetProviderV2");
  const contractProvider = await factory.deploy(nounsTokenAddress);
  await contractProvider.deployed();
  console.log(`      provider="${contractProvider.address}"`);

  const svg = await contractProvider.generateSVGDocument(505);
  await writeFile('./cache/nouns505.svg', svg, ()=>{});

  const addresses = `export const addresses = {\n`
    + `  providerAddress:"${contractProvider.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/nounsV2_${network.name}.ts`, addresses, ()=>{});

  console.log(`npx hardhat verify ${contractProvider.address} ${nounsTokenAddress} --network ${network.name}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

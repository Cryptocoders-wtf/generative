import { ethers, network } from "hardhat";
import { writeFile } from "fs";

import addresses from '@nouns/sdk/dist/contract/addresses.json';

const nounsTokenAddress:string = (network.name == "goerli") ?
  addresses[5].nounsToken: addresses[1].nounsToken;

console.log("nounsToken", nounsTokenAddress);

async function main() {
  const factoryNounsToken = await ethers.getContractFactory("NounsToken");
  const nounsToken = factoryNounsToken.attach(nounsTokenAddress);

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

  const [nounsDescriptor] = await nounsToken.functions.descriptor();
  console.log("nounsDescriptor", nounsDescriptor);
  const descriptor = await ethers.getContractAt("INounsDescriptorV2", nounsDescriptor);

  const svg = await descriptor.generateSVGImage(seeds);
  console.log(svg);
  // const svg = await 

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

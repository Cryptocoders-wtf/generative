import { ethers, network } from "hardhat";
import { writeFile } from "fs";

import addresses from '@nouns/sdk/dist/contract/addresses.json';

const nounsTokenAddress:string = (network.name == "goerli") ?
  addresses[5].nounsToken: addresses[1].nounsToken;
const nounsDescriptorAddressV1:string = (network.name == "goerli") ?
  addresses[5].nounsDescriptor: addresses[1].nounsDescriptor;

console.log("nounsToken", nounsTokenAddress);

async function main() {
  const factoryNounsToken = await ethers.getContractFactory("NounsToken");
  const nounsToken = factoryNounsToken.attach(nounsTokenAddress);

  const [nounsDescriptorAddressV2] = await nounsToken.functions.descriptor();
  console.log("nounsDescriptorV2", nounsDescriptorAddressV2);
  const nounsDescriptorV2 = await ethers.getContractAt("INounsDescriptorV2", nounsDescriptorAddressV2);
  
  const backgroundCountV2 = await nounsDescriptorV2.backgroundCount();
  const bodyCountV2 = await nounsDescriptorV2.bodyCount();
  const accessoryCountV2 = await nounsDescriptorV2.accessoryCount();
  const headCountV2 = await nounsDescriptorV2.headCount();
  const glassesCountV2 = await nounsDescriptorV2.glassesCount();
  console.log(backgroundCountV2.toNumber());
  console.log(bodyCountV2.toNumber());
  console.log(accessoryCountV2.toNumber());
  console.log(headCountV2.toNumber());
  console.log(glassesCountV2.toNumber());

  const nounsDescriptorV1 = await ethers.getContractAt("INounsDescriptor", nounsDescriptorAddressV1);
  const backgroundCountV1 = await nounsDescriptorV1.backgroundCount();
  const bodyCountV1 = await nounsDescriptorV1.bodyCount();
  const accessoryCountV1 = await nounsDescriptorV1.accessoryCount();
  const headCountV1 = await nounsDescriptorV1.headCount();
  const glassesCountV1 = await nounsDescriptorV1.glassesCount();
  console.log(backgroundCountV1.toNumber());
  console.log(bodyCountV1.toNumber());
  console.log(accessoryCountV1.toNumber());
  console.log(headCountV1.toNumber());
  console.log(glassesCountV1.toNumber());

  for (var assetId = 0; assetId < 537; assetId++) {
    const seeds = await nounsToken.functions.seeds(assetId);
    // console.log("seeds", seeds);
    if (seeds.background >= backgroundCountV1
      || seeds.body >= bodyCountV1
      || seeds.accessory >= accessoryCountV1
      || seeds.head >= headCountV1
      || seeds.glasses >= glassesCountV1) {
      console.log(`${assetId},`);      
    }
  }
  // const svg = await nounsDescriptorV2.generateSVGImage(seeds);

  // await writeFile(`./cache/nouns505.svg`, svg, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

/*
403, 405, 406, 407, 410, 415, 416, 417, 419, 422, 423, 434, 450, 452, 453,
454, 456, 460, 471, 474, 475, 479, 487, 490, 492, 497, 499, 505, 512, 519
*/

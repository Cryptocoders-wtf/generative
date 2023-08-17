import * as dotenv from "dotenv";
import { ethers, network } from 'hardhat';

import { images, palette, bgcolors } from "../test/image-original-nouns-data";
// import { abi as nounsDescriptorABI } from "../artifacts/contracts/localNouns/LocalNounsDescriptor.sol/LocalNounsDescriptor";
import { abi as nounsDescriptorABI } from "../artifacts/contracts/external/nouns/NounsDescripter.sol/NounsDescriptor";
import { addresses } from '../../src/utils/addresses';

dotenv.config();

const nounsDescriptorAddress = addresses.nounsDescriptor[network.name];

async function main() {
  var privateKey;
  if (network.name == "localhost" || network.name == "hardhat") {
    privateKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';
  } else {
    privateKey = process.env.PRIVATE_KEY !== undefined ? process.env.PRIVATE_KEY : '';
  }
  const wallet = new ethers.Wallet(privateKey, ethers.provider);
  // const [wallet] = await ethers.getSigners(); // localhost

  // ethers.Contract オブジェクトのインスタンスを作成
  const nounsDescriptor = new ethers.Contract(nounsDescriptorAddress, nounsDescriptorABI, wallet);

  const feeData = await ethers.provider.getFeeData();
  console.log("feeData:" + feeData.gasPrice);

  if (true) {

    console.log(`set Palette start`);
    await nounsDescriptor.addManyColorsToPalette(0, palette, { gasPrice: feeData.gasPrice });
    console.log(`set Palette end`);

    console.log(`set Accessories start`);
    const accessoryChunk = chunkArray(images.accessories, 10);
    for (const chunk of accessoryChunk) {
      await nounsDescriptor.addManyAccessories(chunk.map(({ data }) => data), { gasPrice: feeData.gasPrice });
    }
    console.log(`set Accessories end`);

    console.log(`set Bodies start`);
    const bodiesChunk = chunkArray(images.bodies, 10);
    for (const chunk of bodiesChunk) {
      await nounsDescriptor.addManyBodies(chunk.map(({ data }) => data), { gasPrice: feeData.gasPrice });
    }
    console.log(`set Bodies end`);

    console.log(`set heads start`);
    const headChunk = chunkArray(images.heads, 5);
    for (const chunk of headChunk) {
      await nounsDescriptor.addManyHeads(chunk.map(({ data }) => data), { gasPrice: feeData.gasPrice });
    }
    console.log(`set heads end`);

    console.log(`set glasses start`);
    const glassesChunk = chunkArray(images.glasses, 10);
    for (const chunk of glassesChunk) {
      await nounsDescriptor.addManyGlasses(chunk.map(({ data }) => data), { gasPrice: feeData.gasPrice });
    }
    console.log(`set glasses end`);

    console.log(`set backgrounds start`);
    await nounsDescriptor.addManyBackgrounds(bgcolors, { gasPrice: feeData.gasPrice });
    console.log(`set backgrounds end`);

  }

}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});


interface ImageData {
  filename: string;
  data: string;
}

function chunkArray(imagedata: ImageData[], size: number): ImageData[][] {

  const chunk: ImageData[][] = [];
  for (let i = 0; i < imagedata.length; i += size) {
    chunk.push(imagedata.slice(i, i + size));
  }

  return chunk;
}
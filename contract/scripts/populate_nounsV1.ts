import * as dotenv from "dotenv";
import { ethers, network } from 'hardhat';

import { images, palette, bgcolors } from "../test/image-original-nouns-data";
// import { abi as nounsDescriptorABI } from "../artifacts/contracts/localNouns/LocalNounsDescriptor.sol/LocalNounsDescriptor";
import { abi as nounsDescriptorABI } from "../artifacts/contracts/external/nouns/NounsDescripter.sol/NounsDescriptor";

dotenv.config();

const nounsDescriptorAddress: string = '0xA6f003aa2E8b8EbAe9e3b7792719A08Ea8683107';

async function main() {
  const privateKey = process.env.PRIVATE_KEY !== undefined ? process.env.PRIVATE_KEY : '';
  const wallet = new ethers.Wallet(privateKey, ethers.provider);
  // const [wallet] = await ethers.getSigners(); // localhost

  // ethers.Contract オブジェクトのインスタンスを作成
  const nounsDescriptor = new ethers.Contract(nounsDescriptorAddress, nounsDescriptorABI, wallet);

  if (true) {

    console.log(`set Palette start`);
    await nounsDescriptor.addManyColorsToPalette(0, palette);
    console.log(`set Palette end`);

    console.log(`set Accessories start`);
    const accessoryChunk = chunkArray(images.accessories, 10);
    for (const chunk of accessoryChunk) {
      await nounsDescriptor.addManyAccessories(chunk.map(({ data }) => data));
    }
    console.log(`set Accessories end`);

    console.log(`set Bodies start`);
    const bodiesChunk = chunkArray(images.bodies, 10);
    for (const chunk of bodiesChunk) {
      await nounsDescriptor.addManyBodies(chunk.map(({ data }) => data));
    }
    console.log(`set Bodies end`);

    console.log(`set heads start`);
    const headChunk = chunkArray(images.heads, 10);
    for (const chunk of headChunk) {
      await nounsDescriptor.addManyHeads(chunk.map(({ data }) => data));
    }
    console.log(`set heads end`);

    console.log(`set glasses start`);
    const glassesChunk = chunkArray(images.glasses, 10);
    for (const chunk of glassesChunk) {
      await nounsDescriptor.addManyGlasses(chunk.map(({ data }) => data));
    }
    console.log(`set glasses end`);

    console.log(`set backgrounds start`);
    await nounsDescriptor.addManyBackgrounds(bgcolors);
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
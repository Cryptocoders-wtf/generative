import * as dotenv from "dotenv";
import { ethers, network } from 'hardhat';

import { images, palette, bgcolors } from "../test/image-original-nouns-data";
// import { abi as nounsDescriptorABI } from "../artifacts/contracts/localNouns/LocalNounsDescriptor.sol/LocalNounsDescriptor";
import { abi as nounsDescriptorABI } from "../artifacts/contracts/external/nouns/NounsDescripter.sol/NounsDescriptor";

dotenv.config();

const nounsDescriptorAddress: string = '0x4DCD10c8Da99C062E06dc28f7a26917B3D45dC73';

async function main() {
  var privateKey;
  if (network.name == "localhost") {
    privateKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';
  } else {
    privateKey = process.env.PRIVATE_KEY !== undefined ? process.env.PRIVATE_KEY : '';
  }
  const wallet = new ethers.Wallet(privateKey, ethers.provider);
  // const [wallet] = await ethers.getSigners(); // localhost

  // ethers.Contract オブジェクトのインスタンスを作成
  const nounsDescriptor = new ethers.Contract(nounsDescriptorAddress, nounsDescriptorABI, wallet);

  const seed = {
    background: 0, body: 14, accessory: 132, head: 94, glasses: 18
  };

  const svg = await nounsDescriptor.generateSVGImage(seed);
  console.log(svg);

}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});


interface ImageData {
  filename: string;
  data: string;
}

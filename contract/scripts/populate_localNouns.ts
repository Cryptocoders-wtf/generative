import * as dotenv from "dotenv";
import { ethers, network } from 'hardhat';
import * as fs from 'fs';

import { images, palette } from "../test/image-local-data";
import { abi as localSeederABI } from "../artifacts/contracts/localNouns/LocalNounsSeeder.sol/LocalNounsSeeder";
import { abi as localNounsDescriptorABI } from "../artifacts/contracts/localNouns/LocalNounsDescriptor.sol/LocalNounsDescriptor";
import { abi as localProviderABI } from "../artifacts/contracts/localNouns/LocalNounsProvider.sol/LocalNounsProvider";
import { abi as localTokenABI } from "../artifacts/contracts/LocalNounsToken.sol/LocalNounsToken";

dotenv.config();

const localSeederAddress: string = '0xD00fa9C531CEE42ba319B5Bda19c60e54BEddA41';
const localNounsDescriptorAddress: string = '0xA4D4793f2fFafb1E7278C80565FA7252Ef146623';
const localProviderAddress: string = '0xDC00D91b1FE2bc91C241Ae1E03b30F867789E83e';
const localTokenAddress: string = '0x4958bb35e1aEA77133E46f042d0b5d373141E759';

async function main() {
  const privateKey = process.env.PRIVATE_KEY !== undefined ? process.env.PRIVATE_KEY : '';
  const wallet = new ethers.Wallet(privateKey, ethers.provider);
  // const [wallet] = await ethers.getSigners(); // localhost

  // ethers.Contract オブジェクトのインスタンスを作成
  const localSeeder = new ethers.Contract(localSeederAddress, localSeederABI, wallet);
  const localNounsDescriptor = new ethers.Contract(localNounsDescriptorAddress, localNounsDescriptorABI, wallet);
  const localProvider = new ethers.Contract(localProviderAddress, localProviderABI, wallet);
  const localToken = new ethers.Contract(localTokenAddress, localTokenABI, wallet);

  if (true) {
    // set Palette
    console.log(`set Palette start`);
    await localNounsDescriptor.addManyColorsToPalette(0, palette);
    console.log(`set Palette end`);

    // set Accessories
    console.log(`set Accessories start`);
    const accessoryChunk = chunkArrayByPrefectureId(images.accessories);
    for (const chunk of accessoryChunk) {
      const prefectureId = chunk[0].filename.split('-')[0];
      await localNounsDescriptor.addManyAccessories(prefectureId, chunk.map(({ data }) => data));
      // console.log("chunk:", prefectureId, chunk);
    }
    console.log(`set Accessories end`);

    // set Heads
    console.log(`set Heads start`);
    const headChunk = chunkArrayByPrefectureId(images.heads);
    for (const chunk of headChunk) {
      const prefectureId = chunk[0].filename.split('-')[0];
      await localNounsDescriptor.addManyHeads(prefectureId, chunk.map(({ data }) => data));
      // console.log("chunk:", prefectureId, chunk);
    }
    console.log(`set Heads end`);

  }

  for (var i: number = 1; i <= 47; i++) {
    try {
      await localToken.functions['mint(uint256)'](ethers.BigNumber.from(String(i)), { value: ethers.utils.parseEther('0.001') });
      await localToken.functions['mint(uint256)'](ethers.BigNumber.from(String(i)), { value: ethers.utils.parseEther('0.001') });
      await localToken.functions['mint(uint256)'](ethers.BigNumber.from(String(i)), { value: ethers.utils.parseEther('0.001') });
      console.log(`mint [`, i, `]`);
    } catch (error) {
      console.error(error);
    };
  }

  // console.log(`write file start`);
  // const index = 0;
  // const ret = await localToken.tokenURI(index);
  // const json = Buffer.from(ret.split(",")[1], 'base64').toString();
  // const svgB = Buffer.from(JSON.parse(json)["image"].split(",")[1], 'base64').toString();
  // const svg = Buffer.from(svgB, 'base64').toString();
  // // fs.writeFileSync(`./svg/${index}.svg`, svg, { encoding: 'utf8' });
  // console.log(`write file end`);

}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

interface ImageData {
  filename: string;
  data: string;
}

function chunkArrayByPrefectureId(imagedata: ImageData[]): ImageData[][] {
  let map = new Map<string, ImageData[]>();

  for (let i = 0; i < imagedata.length; i++) {
    // dataが空っぽはスキップ
    if (imagedata[i].data === undefined) {
      console.error("not define data:", imagedata[i].filename);
      continue;
    }

    let id = imagedata[i].filename.split('-')[0];

    if (!map.has(id)) {
      map.set(id, []);
    }
    map.get(id)!.push(imagedata[i]);
  }
  return Array.from(map.values());
}
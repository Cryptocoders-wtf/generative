import * as dotenv from "dotenv";
import { ethers, network } from 'hardhat';
import { addresses } from '../../src/utils/addresses';

const nounsDescriptor = addresses.nounsDescriptor[network.name];

import { images, palette, bgcolors } from "../test/image-local-data";
import { abi as localNounsDescriptorABI } from "../artifacts/contracts/localNouns/LocalNounsDescriptor.sol/LocalNounsDescriptor";

dotenv.config();


const localNounsDescriptorAddress = addresses.localNounsDescriptor[network.name];

async function main() {

  // const privateKey = process.env.PRIVATE_KEY !== undefined ? process.env.PRIVATE_KEY : '';
  // const wallet = new ethers.Wallet(privateKey, ethers.provider);
  const [wallet] = await ethers.getSigners(); // localhost

  // ethers.Contract オブジェクトのインスタンスを作成
  const localNounsDescriptor = new ethers.Contract(localNounsDescriptorAddress, localNounsDescriptorABI, wallet);

  let tx;
  if (true) {
    // set Background Nounsコントラクトを使用するため不要
    // console.log(`set backgrounds start`);
    // tx = await localNounsDescriptor.addManyBackgrounds(bgcolors);
    // console.log(`set backgrounds end:`, tx.hash);

    // set Palette
    console.log(`set Palette start`);
    tx = await localNounsDescriptor.addManyColorsToPalette(0, palette);
    console.log(`set Palette end`, tx.hash);

    // set Accessories
    console.log(`set Accessories start`);
    const accessoryChunk = chunkArrayByPrefectureId(images.accessories);
    for (const chunk of accessoryChunk) {
      const prefectureId = chunk[0].prefectureId;

      // トランザクションエラーで再実行する場合に成功している都道府県をスキップ
      // if (Number(prefectureId) <= 47 ) {
      //   continue;
      // }
      tx = await localNounsDescriptor.addManyAccessories(prefectureId, chunk.map(({ data }) => data), chunk.map(({ filename }) => filename));
      console.log("chunk:", prefectureId, tx.hash);
    }
    console.log(`set Accessories end`);

    // set Heads
    console.log(`set Heads start`);
    const headChunk = chunkArrayByPrefectureId(images.heads);
    for (const chunk of headChunk) {
      const prefectureId = chunk[0].prefectureId;

      // トランザクションエラーで再実行する場合に成功している都道府県をスキップ
      if (Number(prefectureId) == 2 || Number(prefectureId) == 3 ) {
        continue;
      }
      tx = await localNounsDescriptor.addManyHeads(prefectureId, chunk.map(({ data }) => data), chunk.map(({ filename }) => filename));
      console.log("chunk:", prefectureId, tx.hash);
    }
    console.log(`set Heads end`);

  }

}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

interface ImageData {
  prefectureId: string;
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

    let filename = imagedata[i].filename.split('-');
    let id = filename[0];
    imagedata[i].prefectureId = id;
    // filenameの抽出 ex)"35-yamaguchi-white -snake-accessories" -> "white-snake"
    let name = '';
    for (var j = 2; j < filename.length - 1; j++) {
      if (name.length > 0) {
        name += '-';
      }
      name += filename[j].trim();
    }
    imagedata[i].filename = name;
    // console.log("imagedata[i].filename", imagedata[i].filename);
    if (!map.has(id)) {
      map.set(id, []);
    }
    map.get(id)!.push(imagedata[i]);
  }
  return Array.from(map.values());
}
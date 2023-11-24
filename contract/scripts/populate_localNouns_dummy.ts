import * as dotenv from "dotenv";
import { ethers, network } from 'hardhat';
import { addresses } from '../../src/utils/addresses';

const nounsDescriptor = addresses.nounsDescriptor[network.name];

import { images, palette, bgcolors } from "../test/image-local-data_test";
import { abi as localSeederABI } from "../artifacts/contracts/localNouns/LocalNounsSeeder.sol/LocalNounsSeeder";
import { abi as localNounsDescriptorABI } from "../artifacts/contracts/localNouns/LocalNounsDescriptor.sol/LocalNounsDescriptor";
import { abi as localProviderABI } from "../artifacts/contracts/localNouns/LocalNounsProvider.sol/LocalNounsProvider";
import { abi as localTokenABI } from "../artifacts/contracts/LocalNounsToken.sol/LocalNounsToken";
import { abi as localMinterABI } from "../artifacts/contracts/localNouns/LocalNounsMinter.sol/LocalNounsMinter";

dotenv.config();


const localSeederAddress = addresses.localSeeder[network.name];
const localNounsDescriptorAddress = addresses.localNounsDescriptor[network.name];
const localProviderAddress = addresses.localProvider[network.name];
const localTokenAddress = addresses.localNounsToken[network.name];
const localMinterAddress = addresses.localNounsMinter[network.name];

async function main() {

  // const privateKey = process.env.PRIVATE_KEY !== undefined ? process.env.PRIVATE_KEY : '';
  // const wallet = new ethers.Wallet(privateKey, ethers.provider);
  const [wallet] = await ethers.getSigners(); // localhost

  // ethers.Contract オブジェクトのインスタンスを作成
  const localSeeder = new ethers.Contract(localSeederAddress, localSeederABI, wallet);
  const localNounsDescriptor = new ethers.Contract(localNounsDescriptorAddress, localNounsDescriptorABI, wallet);
  const localProvider = new ethers.Contract(localProviderAddress, localProviderABI, wallet);
  const localToken = new ethers.Contract(localTokenAddress, localTokenABI, wallet);
  const localMinter = new ethers.Contract(localMinterAddress, localMinterABI, wallet);

  if (true) {
    // set Background
    // console.log(`set backgrounds start`);
    // await localNounsDescriptor.addManyBackgrounds(bgcolors);
    // console.log(`set backgrounds end`);

    // set Palette
    // console.log(`set Palette start`);
    // await localNounsDescriptor.addManyColorsToPalette(0, palette);
    // console.log(`set Palette end`);

    // set Accessories
    // console.log(`set Accessories start`);
    // const accessoryChunk = chunkArrayByPrefectureId(images.accessories);
    // for (const chunk of accessoryChunk) {
    //   const prefectureId = chunk[0].prefectureId;

    //   // if (Number(prefectureId) == 2) {
    //   await localNounsDescriptor.addManyAccessories(prefectureId, chunk.map(({ data }) => data), chunk.map(({ filename }) => filename));
    //   console.log("chunk:", prefectureId, chunk);
    //   // }
    // }
    // console.log(`set Accessories end`);

    // set Heads
    console.log(`set Heads start`);
    const headChunk = chunkArrayByPrefectureId(images.heads);
    for (const chunk of headChunk) {
      const prefectureId = chunk[0].prefectureId;

      if (Number(prefectureId) > 30) {
      await localNounsDescriptor.addManyHeads(prefectureId, chunk.map(({ data }) => data), chunk.map(({ filename }) => filename));
      console.log("chunk:", prefectureId, chunk);
      }
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
  const head_dummy = '0x00041e1405040001a1014d011801a10118014d01a1014d01be01a101be014d01a1014d0700020001a10118024d0318034d03be034d01a1014d05000100024d034801a101be014801a10148014d0115014d01480118014803be0500010001a1014d014801a1014802be0348034d034801be01a101be0115014d030001000218014d0118014d011801150118014d01180148011801480118011501180348024d030001bc01150118034d0318024d0348031801480118014801be0115030012bc024d02be01480115010012bc0115014d0115014d0248010014bc024d030012bc014d011501bc01180115020012bc024d01bc0218020016bc030014bc014d011501000115014d0cbc014d011506bc024d0100024d0cbc024d03bc014d011503bc0300010010bc024d02bc0400020012010500';
  const accessory_dummy = '0x0017151e0e0200030d0200010005b40100014103b4010d01b40141014101b4030d01b40141014102b4020d01b40141014103b4010d01b40141010003b4010d01b401000200030d0200';
  for (let i = 0; i < imagedata.length; i++) {
    // dataが空っぽはスキップ
    if (imagedata[i].data === undefined) {
      console.error("not define data:", imagedata[i].filename);
      continue;
    }

    let filename = imagedata[i].filename.split('-');
    let id = filename[0];
    imagedata[i].prefectureId = id;
    if (false) {
      if (filename[filename.length - 1] == 'heads') {
        imagedata[i].data = head_dummy;
      } else {
        imagedata[i].data = accessory_dummy;
      }
    }
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
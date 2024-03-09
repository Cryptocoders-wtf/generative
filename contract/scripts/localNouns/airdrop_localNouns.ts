// import * as dotenv from "dotenv";
import { ethers, network } from 'hardhat';
import { addresses } from '../../../src/utils/addresses';

import { abi as localTokenABI } from "../artifacts/contracts/LocalNounsToken.sol/LocalNounsToken";

const localTokenAddress = addresses.localNounsToken[network.name];

async function main() {

  let wallet;
  if (network.name == 'localhost') {
    [wallet] = await ethers.getSigners(); // localhost
  } else {
    const privateKey = process.env.PRIVATE_KEY !== undefined ? process.env.PRIVATE_KEY : '';
    wallet = new ethers.Wallet(privateKey, ethers.provider);

  }

  // ethers.Contract オブジェクトのインスタンスを作成
  const localToken = new ethers.Contract(localTokenAddress, localTokenABI, wallet);

  let tx;

  // 実行委員へミント
  const mintNumForPrefecture = [
    // ['0x4eA84A06F011495B99Aa7202fDca60443107042F',0,3], 【済】
    // ['0x84296321A9Bb88Be24df53d6AbB308f94e44c13A',0,3], 【済】
    // ['0x3E1dc89ab1E3BB8A64bB0f65b65b404f1BF708c3',0,6], 【済】
    // ['0x7AB60415A6712d15DcA1E08E9B72a56b8cC97c77',0,3], 【済】
    // ['0x2072C081C77A476c28d4B2e0F86ED8A789BD8078',0,3], 【済】
    // ['0x4F4bD77781cEeE4914B6bC16633D5437eaBCa5D3',0,3],【済】
    // ['0x39a3e7812F7d5851fc557C550E08Fa75700941E1',0,3],【済】
    ['0x9Cc1d4AF4BD2F9123e66433313be82aFa802393f',0,3],
    // ['0xBc7dC395762d1268d51F8480F9e7e892cAd9175b',0,3], 【済】
  ];

  for (var i = 0; i < mintNumForPrefecture.length; i++) {
    try {
      tx = await localToken.functions['ownerMint']([mintNumForPrefecture[i][0]], [mintNumForPrefecture[i][1]], [mintNumForPrefecture[i][2]]);
      console.log("mint:", mintNumForPrefecture[i], tx.hash);
    } catch (error) {
      console.log("mint error:", mintNumForPrefecture[i], tx.hash);
      // console.error(error);  
    };
    await sleep(1000); // 1秒待機
  }
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

// import * as dotenv from "dotenv";
import { ethers, network } from 'hardhat';
import { addresses } from '../../src/utils/addresses';

const nounsDescriptor = addresses.nounsDescriptor[network.name];

import { abi as localTokenABI } from "../artifacts/contracts/LocalNounsToken.sol/LocalNounsToken";
import { abi as localMinterABI } from "../artifacts/contracts/localNouns/LocalNounsMinter2.sol/LocalNounsMinter2";

const localTokenAddress = addresses.localNounsToken[network.name];
const localMinterAddress = addresses.localNounsMinter[network.name];

async function main() {

  let wallet;
  if (network.name == 'localhost') {
    [wallet] = await ethers.getSigners(); // localhost
  } else {
    const privateKey = process.env.PRIVATE_KEY !== undefined ? process.env.PRIVATE_KEY : '';
    wallet = new ethers.Wallet(privateKey, ethers.provider);

  }

  // ethers.Contract オブジェクトのインスタンスを作成
  const localMinter = new ethers.Contract(localMinterAddress, localMinterABI, wallet);
  const localToken = new ethers.Contract(localTokenAddress, localTokenABI, wallet);

  let tx;

  // ロイヤリティ設定
  const rolyaltyAddresses = [
    '0x4F4bD77781cEeE4914B6bC16633D5437eaBCa5D3', // fuyu256
    '0x7731396aEe82849D0824162e634422Ee7144507D', // miorobo
    '0xBE5f70E61D00acFb8Ba934551103387EE9fd3dB2', // eiba
    '0xA0B9D89F6d17658EAA71fC0b916fCCB248340382' // 運営
  ];
  const rolyaltyRatio = [
    3764, // fuyu256
    1236, // miorobo
    2500, // eiba
    2500  // 運営
  ];
  tx = await localMinter.functions['setRoyaltyAddresses'](rolyaltyAddresses, rolyaltyRatio);
  console.log("ロイヤリティ設定", tx.hash);

  // Minter設定
  tx = await localToken.setMinter(localMinter.address);
  console.log("Minter設定", tx.hash);

}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

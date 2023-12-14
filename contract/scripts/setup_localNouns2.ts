// import * as dotenv from "dotenv";
import { ethers, network } from 'hardhat';
import { addresses } from '../../src/utils/addresses';

const nounsDescriptor = addresses.nounsDescriptor[network.name];

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

  // 都道府県ヘッドのミント

  for (var i = 101; i <= 147; i++) {
    try {
      tx = await localToken.functions['ownerMint']([wallet.address], [i], [3]);
      console.log("mint:", i, tx.hash);
    } catch (error) {
      console.log("mint error:", i, tx.hash);
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

/*
npx hardhat run scripts/localNouns/putTrade_localNouns.ts --network mainnet
*/
// import * as dotenv from "dotenv";
import { ethers, network } from 'hardhat';
import { addresses } from '../../../src/utils/addresses';

import { abi as localTokenABI } from "../../artifacts/contracts/LocalNounsToken.sol/LocalNounsToken";

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

  // トレードへリスト
  const tradeList = [
    [79,[],'0xA5cdC559386d8A5c89671628804234B8cb43bbb9'],
[85,[],'0xA5cdC559386d8A5c89671628804234B8cb43bbb9'],
[88,[],'0xA5cdC559386d8A5c89671628804234B8cb43bbb9'],
[111,[],'0xA5cdC559386d8A5c89671628804234B8cb43bbb9'],
  ];

  for (var i = 0; i < tradeList.length; i++) {
    try {
      tx = await localToken.functions['putTradeLocalNoun'](tradeList[i][0], tradeList[i][1], tradeList[i][2]);
      console.log("trade:", tradeList[i], tx.hash);
    } catch (error) {
      console.log("trade error:", tradeList[i], error);
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

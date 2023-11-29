import * as dotenv from "dotenv";
import { ethers, network } from 'hardhat';
import { addresses } from '../../src/utils/addresses';

const nounsDescriptor = addresses.nounsDescriptor[network.name];

import { abi as localTokenABI } from "../artifacts/contracts/LocalNounsToken.sol/LocalNounsToken";
import { abi as tokenGateABI } from "../artifacts/contracts/libs/AssetTokenGate.sol/AssetTokenGate";

dotenv.config();

const localTokenAddress = addresses.localNounsToken[network.name];
const tokenGateAddress = addresses.tokenGate[network.name];

async function main() {

  let wallet;
  if (network.name == 'localhost') {
    [wallet] = await ethers.getSigners(); // localhost
  } else {
    const privateKey = process.env.PRIVATE_KEY !== undefined ? process.env.PRIVATE_KEY : '';
    wallet = new ethers.Wallet(privateKey, ethers.provider);

  }

  // ethers.Contract オブジェクトのインスタンスを作成
  const tokenGate = new ethers.Contract(tokenGateAddress, tokenGateABI, wallet);
  const localToken = new ethers.Contract(localTokenAddress, localTokenABI, wallet);

  // tokengateに設定
  if (network.name == 'mumbai') {
    const nfts = [
      "0x9f3aBc7b9f17Fb58a367bdA86e6129a2F5849942"  // TEST用
    ];
    await tokenGate.functions['setWhitelist'](nfts);
  } else {
    const nfts = [
      "0x898a7dBFdDf13962dF089FBC8F069Fa7CE92cDBb", // NDJ-PFP
      "0x866648Ef4Dd51e857cA05ea200eD5D5D0c6f93Ce", // NDJ-POAP
      "0x09d53609a3709BBc1206B9Aa8C54DC71625e31aC", // Nounish CNP
      "0x4bE962499cE295b1ed180F923bf9c73b6357DE80"  // pNouns
    ];
    await tokenGate.functions['setWhitelist'](nfts);
  }

  // ロイヤリティ設定
  const rolyaltyAddresses = [
    '0xA0B9D89F6d17658EAA71fC0b916fCCB248340382', // eiba
    '0x52A76a606AC925f7113B4CC8605Fe6bCad431EbB', // takumi(仮)
    '0x35e5664686475Fe0Fb05300a1708B3C7243F916e', // deynao(仮)
    '0x2072C081C77A476c28d4B2e0F86ED8A789BD8078'  // udon(仮)
  ];
  const rolyaltyRatio = [
    5, // eiba
    2, // takumi
    2, // deynao
    1  // udon
  ];
  await localToken.functions['setRoyaltyAddresses'](rolyaltyAddresses, rolyaltyRatio);

  // 運営用初期ミント
  // 300体を都道府県割合で運用へミント
  const mintNumForPrefecture = [
    [13, 10],
    [14, 10],
    [27, 10],
    [23, 10],
    [11, 10],
    [12, 10],
    [28, 9],
    [1, 9],
    [40, 9],
    [22, 8],
    [8, 8],
    [34, 8],
    [26, 8],
    [4, 8],
    [15, 8],
    [20, 7],
    [21, 7],
    [10, 7],
    [9, 6],
    [33, 6],
    [7, 6],
    [24, 6],
    [43, 6],
    [46, 6],
    [47, 6],
    [25, 6],
    [35, 6],
    [29, 5],
    [38, 5],
    [42, 5],
    [2, 5],
    [3, 5],
    [17, 5],
    [44, 5],
    [45, 5],
    [6, 5],
    [16, 5],
    [37, 4],
    [5, 4],
    [30, 4],
    [19, 4],
    [41, 4],
    [18, 4],
    [36, 4],
    [39, 4],
    [32, 4],
    [31, 4]
  ];

  for (var i = 0; i < mintNumForPrefecture.length; i++) {
    try {
      await localToken.functions['ownerMint']([wallet.address], [mintNumForPrefecture[i][0]], [mintNumForPrefecture[i][1]]);
      console.log("mint:", mintNumForPrefecture[i]);
    } catch (error) {
      console.log("mint error:", mintNumForPrefecture[i]);
      // console.error(error);  
    };
  }
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

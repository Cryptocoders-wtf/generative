// SPDX-License-Identifier: MIT

/*
 * Created by @eiba8884
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/IAssetProviderExMint.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/interfaces/IERC165.sol';
import 'randomizer.sol/Randomizer.sol';

import { INounsDescriptor } from './interfaces/INounsDescriptor.sol';
import { INounsSeeder } from './interfaces/INounsSeeder.sol';

contract LocalNounsProvider2 is IAssetProviderExMint, IERC165, Ownable {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;

  string constant providerKey = 'LocalNouns';
  address public receiver;

  uint256 public nextTokenId;

  INounsDescriptor public immutable descriptor;
  INounsDescriptor public immutable localDescriptor;

  mapping(uint256 => uint256) public tokenIdToPrefectureId;
  mapping(uint256 => string) public prefectureName;
  mapping(uint256 => uint256) public mintNumberPerPrefecture; // 都道府県ごとのミント数
  // mapping(uint256 => uint256) public prefectureRatio; // ランダムミント時に決定される都道府県の割合
  uint256 totalPrefectureRatio;

  uint256[5] ratioRank = [5, 4, 3, 3, 2];
  uint256[5] accumulationRatioRank;
  uint256 accumulationRatioRankTotal;
  mapping(uint256 => uint256[]) public prefectureRatio;

  constructor(INounsDescriptor _descriptor, INounsDescriptor _localDescriptor) {
    receiver = owner();

    descriptor = _descriptor;
    localDescriptor = _localDescriptor;

    prefectureName[1] = 'Hokkaido';
    prefectureName[2] = 'Aomori';
    prefectureName[3] = 'Iwate';
    prefectureName[4] = 'Miyagi';
    prefectureName[5] = 'Akita';
    prefectureName[6] = 'Yamagata';
    prefectureName[7] = 'Fukushima';
    prefectureName[8] = 'Ibaraki';
    prefectureName[9] = 'Tochigi';
    prefectureName[10] = 'Gunma';
    prefectureName[11] = 'Saitama';
    prefectureName[12] = 'Chiba';
    prefectureName[13] = 'Tokyo';
    prefectureName[14] = 'Kanagawa';
    prefectureName[15] = 'Niigata';
    prefectureName[16] = 'Toyama';
    prefectureName[17] = 'Ishikawa';
    prefectureName[18] = 'Fukui';
    prefectureName[19] = 'Yamanashi';
    prefectureName[20] = 'Nagano';
    prefectureName[21] = 'Gifu';
    prefectureName[22] = 'Shizuoka';
    prefectureName[23] = 'Aichi';
    prefectureName[24] = 'Mie';
    prefectureName[25] = 'Shiga';
    prefectureName[26] = 'Kyoto';
    prefectureName[27] = 'Osaka';
    prefectureName[28] = 'Hyogo';
    prefectureName[29] = 'Nara';
    prefectureName[30] = 'Wakayama';
    prefectureName[31] = 'Tottori';
    prefectureName[32] = 'Shimane';
    prefectureName[33] = 'Okayama';
    prefectureName[34] = 'Hiroshima';
    prefectureName[35] = 'Yamaguchi';
    prefectureName[36] = 'Tokushima';
    prefectureName[37] = 'Kagawa';
    prefectureName[38] = 'Ehime';
    prefectureName[39] = 'Kochi';
    prefectureName[40] = 'Fukuoka';
    prefectureName[41] = 'Saga';
    prefectureName[42] = 'Nagasaki';
    prefectureName[43] = 'Kumamoto';
    prefectureName[44] = 'Oita';
    prefectureName[45] = 'Miyazaki';
    prefectureName[46] = 'Kagoshima';
    prefectureName[47] = 'Okinawa';

    prefectureRatio[0] = [13, 14, 27, 23, 11, 12, 28, 1, 40];
    prefectureRatio[1] = [22, 8, 34, 26, 4, 15, 20, 21, 10];
    prefectureRatio[2] = [9, 33, 7, 24, 43, 46, 47, 25, 35];
    prefectureRatio[3] = [29, 38, 42, 2, 3, 17, 44, 45, 6, 16];
    prefectureRatio[4] = [37, 5, 30, 19, 41, 18, 36, 39, 32, 31];

    for (uint256 i = 0; i < ratioRank.length; i++) {
      accumulationRatioRankTotal += ratioRank[i];
      accumulationRatioRank[i] = accumulationRatioRankTotal;
    }
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IAssetProvider).interfaceId || interfaceId == type(IERC165).interfaceId;
  }

  function getOwner() external view override returns (address) {
    return owner();
  }

  function getProviderInfo() external view override returns (ProviderInfo memory) {
    return ProviderInfo(providerKey, 'Logo', this);
  }

  function totalSupply() external pure override returns (uint256) {
    return 0; // indicating "dynamically (but deterministically) generated from the given assetId)
  }

  function processPayout(uint256 _assetId) external payable override {
    address payable payableTo = payable(receiver);
    payableTo.transfer(msg.value);
    emit Payout(providerKey, _assetId, payableTo, msg.value);
  }

  function setReceiver(address _receiver) external onlyOwner {
    receiver = _receiver;
  }

  function generateSeed(
    uint256 prefectureId,
    uint256 _assetId
  ) internal view returns (INounsSeeder.Seed memory mixedSeed) {
    uint256 pseudorandomness;
    Randomizer.Seed memory seed = Randomizer.Seed(_assetId, 0);

    // LocalNounsのヘッドを決定
    uint256 headCount = localDescriptor.headCountInPrefecture(prefectureId);
    (seed, pseudorandomness) = seed.random(headCount);
    uint256 headPartId = localDescriptor.headInPrefecture(prefectureId, pseudorandomness);

    // LocalNounsのアクセサリを決定
    uint256 accessoryCount = localDescriptor.accessoryCountInPrefecture(prefectureId % 100); // 1,2桁目：都道府県番号、3桁目以降：バージョン番号
    (seed, pseudorandomness) = seed.random(accessoryCount);
    uint256 accesoryPartId = localDescriptor.accessoryInPrefecture(prefectureId % 100, pseudorandomness);

    // Nounsのバックグラウンドを決定
    uint256 backgroundCount = descriptor.backgroundCount();
    (seed, pseudorandomness) = seed.random(backgroundCount);
    uint256 backgroundPartId = pseudorandomness;

    // Nounsのボディを決定
    uint256 bodyCount = descriptor.bodyCount();
    (seed, pseudorandomness) = seed.random(bodyCount);
    uint256 bodyPartId = pseudorandomness;

    // Nounsのグラスを決定
    uint256 glassesCount = descriptor.glassesCount();
    (seed, pseudorandomness) = seed.random(glassesCount);
    uint256 glassesPartId = pseudorandomness;

    mixedSeed = INounsSeeder.Seed({
      background: uint48(backgroundPartId),
      body: uint48(bodyPartId),
      accessory: uint48(accesoryPartId),
      head: uint48(headPartId),
      glasses: uint48(glassesPartId)
    });
  }

  function generateSVGPart(uint256 _assetId) public view override returns (string memory svgPart, string memory tag) {
    INounsSeeder.Seed memory seed = generateSeed(tokenIdToPrefectureId[_assetId], _assetId);

    svgPart = localDescriptor.generateSVGImage(seed);
    tag = string('');
  }

  function generateTraits(uint256 _assetId) external view override returns (string memory traits) {
    INounsSeeder.Seed memory seed = generateSeed(tokenIdToPrefectureId[_assetId], _assetId);

    uint256 headPartsId = seed.head;
    uint256 accessoryPartsId = seed.accessory;
    traits = string(
      abi.encodePacked(
        '{"trait_type": "prefecture" , "value":"',
        prefectureName[tokenIdToPrefectureId[_assetId] % 100],
        '"}',
        ',{"trait_type": "head" , "value":"',
        localDescriptor.headName(headPartsId),
        '"}',
        ',{"trait_type": "accessory" , "value":"',
        localDescriptor.accessoryName(accessoryPartsId),
        '"}'
      )
    );
  }

  // テスト用にpublic
  function determinePrefectureId(uint256 _assetId) public view returns (uint256) {
    uint256 rank = _assetId % accumulationRatioRankTotal;
    for (uint256 i = 0; i < accumulationRatioRank.length; i++) {
      if (rank < accumulationRatioRank[i]) {
        rank = i;
        break;
      }
    }
    return prefectureRatio[rank][_assetId % prefectureRatio[rank].length];
  }

  function mint(uint256 _prefectureId, uint256 _assetId) external returns (uint256) {
    uint256 prefectureId;
    // 末尾2桁が00の場合は都道府県をランダムに決定する
    if (_prefectureId % 100 == 0) {
      prefectureId = _prefectureId + determinePrefectureId(_assetId);
    } else {
      prefectureId = _prefectureId;
    }

    tokenIdToPrefectureId[_assetId] = prefectureId;
    mintNumberPerPrefecture[prefectureId % 100]++;
    nextTokenId++;

    return _assetId;
  }

  function getPrefectureId(uint256 _tokenId) external view override returns (uint256) {
    return tokenIdToPrefectureId[_tokenId];
  }
}

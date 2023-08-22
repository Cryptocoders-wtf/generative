// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/IAssetProviderExMint.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/interfaces/IERC165.sol';

import { INounsDescriptor } from './interfaces/INounsDescriptor.sol';
import { INounsSeeder } from './interfaces/INounsSeeder.sol';
import { ILocalNounsSeeder } from './interfaces/ILocalNounsSeeder.sol';
import { NFTDescriptor } from '../external/nouns/libs/NFTDescriptor.sol';

contract LocalNounsProvider is IAssetProviderExMint, IERC165, Ownable {
  using Strings for uint256;

  string constant providerKey = 'LocalNouns';
  address public receiver;

  uint256 public nextTokenId;

  INounsDescriptor public immutable descriptor;
  INounsDescriptor public immutable localDescriptor;
  INounsSeeder public immutable seeder;
  ILocalNounsSeeder public immutable localSeeder;

  mapping(uint256 => INounsSeeder.Seed) public seeds;
  mapping(uint256 => uint256) public tokenIdToPrefectureId;
  mapping(uint256 => string) public prefectureName;

  constructor(
    INounsDescriptor _descriptor,
    INounsDescriptor _localDescriptor,
    INounsSeeder _seeder,
    ILocalNounsSeeder _localSeeder
  ) {
    receiver = owner();

    descriptor = _descriptor;
    localDescriptor = _localDescriptor;
    seeder = _seeder;
    localSeeder = _localSeeder;

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
    INounsSeeder.Seed memory seed1 = seeder.generateSeed(_assetId, descriptor);
    ILocalNounsSeeder.Seed memory seed2 = localSeeder.generateSeed(prefectureId, _assetId, localDescriptor);

    mixedSeed = INounsSeeder.Seed({
      background: seed1.background,
      body: seed1.body,
      accessory: seed2.accessory,
      head: seed2.head,
      glasses: seed1.glasses
    });
  }

  function generateSVGPart(uint256 _assetId) public view override returns (string memory svgPart, string memory tag) {
    // INounsSeeder.Seed memory seed = generateSeed(_assetId);
    INounsSeeder.Seed memory seed = seeds[_assetId];
    svgPart = localDescriptor.generateSVGImage(seed);

    // generateSVGImage
    tag = string('');
    // svgPart = string("");
  }

  function generateTraits(uint256 _assetId) external view override returns (string memory traits) {
    uint256 headPartsId = seeds[_assetId].head;
    uint256 accessoryPartsId = seeds[_assetId].accessory;
    traits = string(
      abi.encodePacked('{"trait_type": "prefecture" , "value":"', prefectureName[tokenIdToPrefectureId[_assetId]], '"}',
      ',{"trait_type": "head" , "value":"', localDescriptor.headName(headPartsId), '"}',
      ',{"trait_type": "accessory" , "value":"', localDescriptor.accessoryName(accessoryPartsId), '"}')
    );
  }

  function mint(uint256 prefectureId, uint256 _assetId) external returns (uint256) {
    seeds[_assetId] = generateSeed(prefectureId, _assetId);
    tokenIdToPrefectureId[_assetId] = prefectureId % 100; // 1,2桁目：都道府県番号、3桁目以降：バージョン番号
    nextTokenId++;

    return _assetId;
  }
}

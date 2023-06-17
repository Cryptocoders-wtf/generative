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
  ILocalNounsSeeder public immutable localSeader;
  
  mapping(uint256 => INounsSeeder.Seed) public seeds;

  constructor(
              INounsDescriptor _descriptor,
              INounsDescriptor _localDescriptor,
              INounsSeeder _seeder,
              ILocalNounsSeeder _localSeader
              ) {
      receiver = owner();

      descriptor = _descriptor;
      localDescriptor = _localDescriptor;
      seeder = _seeder;
      localSeader = _localSeader;
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

  function generateSeed(uint256 prefectureId, uint256 _assetId) internal view returns (INounsSeeder.Seed memory mixedSeed) {
      INounsSeeder.Seed memory seed1 = seeder.generateSeed(_assetId, descriptor);
      ILocalNounsSeeder.Seed memory seed2 = localSeader.generateSeed(prefectureId, _assetId, localDescriptor);

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
      tag = string("");
      // svgPart = string("");
  }

  function generateTraits(uint256 _assetId) external pure override returns (string memory traits) {
    // nothing to return
  }

  function mint(uint256 prefectureId, uint256 _assetId) external returns (uint256) {
      if (nextTokenId == _assetId) {
         seeds[_assetId] = generateSeed(prefectureId, _assetId);
         nextTokenId ++;
      }
      
     return _assetId;
  }

  

}

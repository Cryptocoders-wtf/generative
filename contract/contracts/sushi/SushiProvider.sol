// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import 'assetprovider.sol/IAssetProvider.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/interfaces/IERC165.sol';

import { INounsDescriptor } from './interfaces/INounsDescriptor.sol';
import { INounsSeeder } from './interfaces/INounsSeeder.sol';
import { NFTDescriptor2 } from './libs/NFTDescriptor2.sol';

contract SushiNounsProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint256;


  string constant providerKey = 'SushiNouns';
  address public receiver;

  INounsDescriptor public immutable descriptor;
  INounsDescriptor public immutable sushidescriptor;
  INounsSeeder public immutable seeder;
  INounsSeeder public immutable sushiseeder;
  
  constructor(
              INounsDescriptor _descriptor,
              INounsDescriptor _sushidescriptor,
              INounsSeeder _seeder,
              INounsSeeder _sushiseeder
              ) {
      receiver = owner();

      descriptor = _descriptor;
      sushidescriptor = _sushidescriptor;
      seeder = _seeder;
      sushiseeder = _sushiseeder;
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

  function generateSVGPart(uint256 _assetId) public view override returns (string memory svgPart, string memory tag) {
      INounsSeeder.Seed memory seed1 = seeder.generateSeed(_assetId, descriptor);
      INounsSeeder.Seed memory seed2 = sushiseeder.generateSeed(_assetId, sushidescriptor);

      INounsSeeder.Seed memory mixedSeed = INounsSeeder.Seed({
          background: seed1.background,
          body: seed1.body,
          accessory: seed2.accessory,
          head: seed2.head,
          glasses: seed1.glasses
      });

      svgPart = sushidescriptor.genericDataURI("", "", mixedSeed);

      // generateSVGImage
      tag = string("");
      // svgPart = string("");
  }

  function generateTraits(uint256 _assetId) external pure override returns (string memory traits) {
    // nothing to return
  }

}

// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import "assetprovider.sol/IAssetProvider.sol";
import '@openzeppelin/contracts/interfaces/IERC165.sol';
import "../providers/NounsAssetProvider.sol";

contract DotProvider is IAssetProvider, IERC165, Ownable {
  NounsAssetProvider public provider;

  constructor(NounsAssetProvider _provider) {
    provider = _provider;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return
      interfaceId == type(IAssetProvider).interfaceId ||
      interfaceId == type(IERC165).interfaceId;
  }

  function getOwner() external override view returns (address) {
    return owner();
  }

  function getProviderInfo() external view override returns(ProviderInfo memory) {
    ProviderInfo memory info = provider.getProviderInfo();
    return ProviderInfo(string(abi.encodePacked(info.key, "_dot32")), string(abi.encodePacked(info.name, " Dot")), this);
  }

  function totalSupply() external view override returns(uint256) {
    return provider.getNounsTotalSuppy(); 
  }

  function processPayout(uint256 _assetId) external override payable {
    provider.processPayout{value:msg.value}(_assetId);
  }

  function generateTraits(uint256 _assetId) external view returns (string memory traits) {
    traits = provider.generateTraits(_assetId);
  }

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    (svgPart, tag) = provider.getNounsSVGPart(_assetId);
    svgPart = string(abi.encodePacked(svgPart,
      '<pattern id="dot32patten" x="0" y="0" width="0.03125" height=".03125">'
      '<rect width="32" height="32" fill="black"/>'
      '<circle cx="16" cy="16" r="16" fill="white"/>'
      '</pattern>'
      '<mask id="dot32mask">'
      '<rect fill="url(#dot32patten)" stroke="black" width="100%" height="100%"/>'
      '</mask>'
      '<g id="', tag, '_dot32">'
      '<rect width="1024" height="1024" fill="#d5d7e1" opacity="0.1" />'
      '<use href="#',tag,'" mask="url(#dot32mask)"/>'
      '</g>'));
    tag = string(abi.encodePacked(tag, '_dot32'));  
  }
}
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
import "../packages/graphics/SVG.sol";

contract DotProvider is IAssetProvider, IERC165, Ownable {
  using Vector for Vector.Struct;
  using Path for uint[];
  using SVG for SVG.Element;

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
    string memory tag0;
    (svgPart, tag0) = provider.getNounsSVGPart(_assetId);
    tag = string(abi.encodePacked(tag, '_dot32'));

    svgPart = string(SVG.list([
      SVG.element(bytes(svgPart)),
      SVG.pattern("dot32patten", "0 0 32 32", "0.03125", ".03125", SVG.list([
        SVG.rect(0, 0, 32, 32).fill("black"),
        SVG.circle(16, 16, 16).fill("white")
      ])),
      SVG.mask("dot32mask",
        SVG.rect().fillRef("dot32patten")
      ),
      SVG.group([
        SVG.rect().fill("#d5d7e1"),
        SVG.use(tag0).mask("dot32mask")
      ]).id(tag)
    ]).svg());
  }
}
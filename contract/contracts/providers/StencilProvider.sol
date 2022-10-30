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
import "randomizer.sol/Randomizer.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/interfaces/IERC165.sol';
import "../interfaces/IColorSchemes.sol";
import "../interfaces/ILayoutGenerator.sol";

/**
 * MultiplexProvider create a new asset provider from another asset provider,
 * which draws multiple assets with the same set of provider-specific properties.
 */
contract StencilProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;

  ILayoutGenerator public generator;
  IColorSchemes public colorSchemes;

  constructor(ILayoutGenerator _generator, IColorSchemes _colorSchemes) {
    generator = _generator;
    colorSchemes = _colorSchemes;
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
    return ProviderInfo("circles", "Circles", this);
  }

  function totalSupply() external pure override returns(uint256) {
    return 0;
  }

  function processPayout(uint256 _assetId) external override payable {
    address payable payableTo = payable(owner());
    payableTo.transfer(msg.value);
    emit Payout("clrcles", _assetId, payableTo, msg.value);
  }

  function generateTraits(uint256 _assetId) external view returns (string memory) {
    return colorSchemes.generateTraits(_assetId);
  }

  struct Properties {
    string[] scheme;
  }

  function concat(bytes[] memory parts) public pure returns (bytes memory ret) {
    for (uint i = 0; i < parts.length; i++) {
      ret = abi.encodePacked(ret, parts[i]);
    }
  }

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    Properties memory props;
    Randomizer.Seed memory seed;
    (seed, props.scheme) = colorSchemes.getColorScheme(_assetId);
    ILayoutGenerator.Node[] memory nodes;
    tag = string(abi.encodePacked("circles", _assetId.toString()));

    (seed, nodes) = generator.generate(seed, 18 + 50 * 0x100 + 80 * 0x10000);
    bytes[] memory parts = new bytes[](nodes.length);
    for (uint i = 0; i < nodes.length; i++) {
      ILayoutGenerator.Node memory node = nodes[i];
      node.size /= 2;
      node.x += node.size;
      node.y += node.size;
      parts[i] = abi.encodePacked(
        '<circle cx="',node.x.toString(),'" cy="',node.y.toString(),'" r="',node.size.toString(),'"'
          ' fill="black" />'
      );  
    }
    svgPart = string(abi.encodePacked(
      '<mask id="',tag,'_mask">'
      '<rect x="0" y="0" width="100%" height="100%" fill="white"/>',
      concat(parts),
      '</mask>'
      '<g id="',tag,'" mask="url(#', tag ,'_mask)">'
      '<rect x="0" y="0" width="100%" height="100%" />',
      '</g>'
    ));
  }
}
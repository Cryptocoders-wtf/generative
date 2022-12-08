// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import 'assetprovider.sol/IAssetProvider.sol';
import 'randomizer.sol/Randomizer.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/interfaces/IERC165.sol';
import '../packages/graphics/SVG.sol';
import '../interfaces/IColorSchemes.sol';
import '../interfaces/ILayoutGenerator.sol';

/**
 * MultiplexProvider create a new asset provider from another asset provider,
 * which draws multiple assets with the same set of provider-specific properties.
 */
contract CirclesProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using SVG for SVG.Element;
  using BytesArray for bytes[];

  ILayoutGenerator public generator;
  IColorSchemes public colorSchemes;

  constructor(ILayoutGenerator _generator, IColorSchemes _colorSchemes) {
    generator = _generator;
    colorSchemes = _colorSchemes;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IAssetProvider).interfaceId || interfaceId == type(IERC165).interfaceId;
  }

  function getOwner() external view override returns (address) {
    return owner();
  }

  function getProviderInfo() external view override returns (ProviderInfo memory) {
    return ProviderInfo('circles', 'Circles', this);
  }

  function totalSupply() external pure override returns (uint256) {
    return 0;
  }

  function processPayout(uint256 _assetId) external payable override {
    address payable payableTo = payable(owner());
    payableTo.transfer(msg.value);
    emit Payout('clrcles', _assetId, payableTo, msg.value);
  }

  function generateTraits(uint256 _assetId) external view returns (string memory) {
    return colorSchemes.generateTraits(_assetId);
  }

  struct Properties {
    string[] scheme;
  }

  function generateSVGPart(uint256 _assetId) external view override returns (string memory svgPart, string memory tag) {
    Properties memory props;
    Randomizer.Seed memory seed;
    (seed, props.scheme) = colorSchemes.getColorScheme(_assetId);
    for (uint i = 0; i < props.scheme.length; i++) {
      props.scheme[i] = string(abi.encodePacked('#', props.scheme[i]));
    }
    ILayoutGenerator.Node[] memory nodes;
    tag = string(abi.encodePacked('circles', _assetId.toString()));

    (seed, nodes) = generator.generate(seed, 18 + 50 * 0x100 + 80 * 0x10000);
    bytes[] memory parts = new bytes[](nodes.length);
    for (uint i = 0; i < nodes.length; i++) {
      ILayoutGenerator.Node memory node = nodes[i];
      node.size /= 2;
      node.x += node.size;
      node.y += node.size;
      parts[i] = SVG
        .circle(int(node.x), int(node.y), int(node.size))
        .fill(props.scheme[i % props.scheme.length])
        .stroke('black', 10)
        .svg();
    }
    svgPart = string(SVG.group(parts.packed()).id(tag).svg());
  }
}

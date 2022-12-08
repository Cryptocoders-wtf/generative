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
import '../interfaces/IColorSchemes.sol';
import '../interfaces/ILayoutGenerator.sol';
import 'bytes-array.sol/BytesArray.sol';
import '../packages/graphics/SVG.sol';

/**
 * MultiplexProvider create a new asset provider from another asset provider,
 * which draws multiple assets with the same set of provider-specific properties.
 */
contract StencilProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using BytesArray for bytes[];
  using SVG for SVG.Element;

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
    return ProviderInfo('stencil', 'Stencil', this);
  }

  function totalSupply() external pure override returns (uint256) {
    return 0;
  }

  function processPayout(uint256 _assetId) external payable override {
    address payable payableTo = payable(owner());
    payableTo.transfer(msg.value);
    emit Payout('stencil', _assetId, payableTo, msg.value);
  }

  function generateTraits(uint256 _assetId) external view returns (string memory) {
    return colorSchemes.generateTraits(_assetId);
  }

  function generateSVGPart(uint256 _assetId) external view override returns (string memory svgPart, string memory tag) {
    Randomizer.Seed memory seed;
    string[] memory scheme;
    (seed, scheme) = colorSchemes.getColorScheme(_assetId);
    for (uint i = 0; i < scheme.length; i++) {
      scheme[i] = string(abi.encodePacked('#', scheme[i]));
    }

    ILayoutGenerator.Node[] memory nodes;
    (seed, nodes) = generator.generate(seed, 0 + 30 * 0x100 + 60 * 0x10000);
    bytes[] memory parts = new bytes[](nodes.length);
    for (uint i = 0; i < nodes.length; i++) {
      ILayoutGenerator.Node memory node = nodes[i];
      uint h;
      (seed, h) = seed.random(3);
      parts[i] = SVG.rect(int(node.x), int(node.y), node.size, (node.size / 5) * (h + 2)).svg();
    }

    tag = string(abi.encodePacked('stencil', _assetId.toString()));
    string memory stencil = string(abi.encodePacked(tag, '_stencil'));
    svgPart = string(
      SVG.packed(
        [
          SVG.stencil(parts.packed()).id(string(abi.encodePacked(tag, '_mask'))),
          SVG.rect().mask(string(abi.encodePacked(tag, '_mask'))).id(stencil),
          SVG
            .group(
              [
                SVG.use(stencil).fill(scheme[1]),
                SVG.use(stencil).fill(scheme[2]).transform('rotate(90 512 512)'),
                SVG.use(stencil).fill(scheme[3]).transform('rotate(180 512 512)'),
                SVG.use(stencil).fill(scheme[4]).transform('rotate(270 512 512)')
              ]
            )
            .id(tag)
        ]
      )
    );
  }
}

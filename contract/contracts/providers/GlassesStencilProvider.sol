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

/**
 * MultiplexProvider create a new asset provider from another asset provider,
 * which draws multiple assets with the same set of provider-specific properties.
 */
contract GlassesStencilProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
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
    return ProviderInfo('glasses', 'Glasses', this);
  }

  function totalSupply() external pure override returns (uint256) {
    return 0;
  }

  function processPayout(uint256 _assetId) external payable override {
    address payable payableTo = payable(owner());
    payableTo.transfer(msg.value);
    emit Payout('glasses', _assetId, payableTo, msg.value);
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
    ILayoutGenerator.Node[] memory nodes;
    tag = string(abi.encodePacked('glasses', _assetId.toString()));

    (seed, nodes) = generator.generate(seed, 25 + 50 * 0x100 + 60 * 0x10000);
    bytes[] memory parts = new bytes[](nodes.length);
    for (uint i = 0; i < nodes.length; i++) {
      ILayoutGenerator.Node memory node = nodes[i];
      uint h;
      (seed, h) = seed.random(4);
      parts[i] = abi.encodePacked(
        '<g transform="translate(',
        node.x.toString(),
        ',',
        node.y.toString(),
        ') scale(',
        node.scale,
        ',',
        node.scale,
        ') rotate(',
        (h * 90).toString(),
        ' 512 512)">'
        '<use href="#nouns_glass"/>'
        '<use y="-341" href="#nouns_glass"/>'
        '<use y="341" href="#nouns_glass"/>'
        '</g>'
      );
    }
    svgPart = string(
      abi.encodePacked(
        '<g id="nouns_glass">'
        '<rect x="262" y="362" width="300" height="300" fill="black"/>'
        '<rect x="662" y="362" width="300" height="300" fill="black"/>'
        '<rect x="112" y="462" width="800" height="50" fill="black"/>'
        '<rect x="112" y="462" width="50" height="150" fill="black"/>'
        '<rect x="312" y="412" width="100" height="200" fill="white"/>'
        '<rect x="712" y="412" width="100" height="200" fill="white"/>'
        '</g>'
        '<mask id="',
        tag,
        '_mask">'
        '<rect x="0" y="0" width="100%" height="100%" fill="white"/>',
        parts.packed(),
        '</mask>\n'
        '<rect id="',
        tag,
        '_stencil" mask="url(#',
        tag,
        '_mask)" '
        'x="0" y="0" width="100%" height="100%" />\n'
      )
    );
    svgPart = string(
      abi.encodePacked(
        svgPart,
        '<g id="',
        tag,
        '" >\n'
        '<rect width="100%" height="100%" fill="#',
        props.scheme[0],
        '" />\n'
        '<use href="#',
        tag,
        '_stencil" fill="#',
        props.scheme[1],
        '" transform="rotate(90 512 512)"/>\n'
        '<use href="#',
        tag,
        '_stencil" fill="#',
        props.scheme[2],
        '" transform="rotate(180 512 512)"/>\n'
        '<use href="#',
        tag,
        '_stencil" fill="#',
        props.scheme[3],
        '" transform="rotate(270 512 512)"/>\n'
        '<use href="#',
        tag,
        '_stencil" fill="white" />\n'
        '</g>\n'
      )
    );
  }
}

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
import "../packages/graphics/SVG.sol";
import "../interfaces/IColorSchemes.sol";
import "../interfaces/ILayoutGenerator.sol";
import "bytes-array.sol/BytesArray.sol";

/**
 * MultiplexProvider create a new asset provider from another asset provider,
 * which draws multiple assets with the same set of provider-specific properties.
 */
contract CircleStencilProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using BytesArray for bytes[];
  using SVG for SVG.Tag;

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
    return ProviderInfo("clrcleStencil", "Circle Stencil", this);
  }

  function totalSupply() external pure override returns(uint256) {
    return 0;
  }

  function processPayout(uint256 _assetId) external override payable {
    address payable payableTo = payable(owner());
    payableTo.transfer(msg.value);
    emit Payout("clrcleStencil", _assetId, payableTo, msg.value);
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
    tag = string(abi.encodePacked("clrcleStencil", _assetId.toString()));

    (seed, nodes) = generator.generate(seed, 18 + 50 * 0x100 + 80 * 0x10000);
    bytes[] memory parts = new bytes[](nodes.length);
    for (uint i = 0; i < nodes.length; i++) {
      ILayoutGenerator.Node memory node = nodes[i];
      node.size /= 2;
      node.x += node.size;
      node.y += node.size;
      parts[i] = abi.encodePacked(
        '<circle cx="',node.x.toString(),'" cy="',node.y.toString(),'" r="',node.size.toString(),'" />'
      );  
    }
    svgPart = string(abi.encodePacked(
      SVG.stencil(parts.packed())
        .id(string(abi.encodePacked(tag, '_mask')))
        .svg(),
      '<rect id="',tag,'_stencil" mask="url(#', tag ,'_mask)" '
        'x="0" y="0" width="100%" height="100%" />\n'));
    svgPart = string(abi.encodePacked(svgPart,
      '<g id="',tag,'" >\n'
      '<use href="#', tag ,'_stencil" fill="#', props.scheme[1], '" />\n'
      '<use href="#', tag ,'_stencil" fill="#', props.scheme[2], '" transform="rotate(90 512 512)"/>\n'
      '<use href="#', tag ,'_stencil" fill="#', props.scheme[3], '" transform="rotate(180 512 512)"/>\n'
      '<use href="#', tag ,'_stencil" fill="#', props.scheme[4], '" transform="rotate(270 512 512)"/>\n'
      '</g>\n'
    ));
  }
}
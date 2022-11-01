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
import "bytes-array.sol/BytesArray.sol";

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

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    Properties memory props;
    Randomizer.Seed memory seed;
    (seed, props.scheme) = colorSchemes.getColorScheme(_assetId);
    ILayoutGenerator.Node[] memory nodes;
    tag = string(abi.encodePacked("circles", _assetId.toString()));

    (seed, nodes) = generator.generate(seed, 0 + 30 * 0x100 + 60 * 0x10000);
    bytes[] memory parts = new bytes[](nodes.length);
    for (uint i = 0; i < nodes.length; i++) {
      ILayoutGenerator.Node memory node = nodes[i];
      uint h;
      (seed, h) = seed.random(3);
      parts[i] = abi.encodePacked(
        '<rect x="0" y="0"'
          ' width="1024" height="',(uint(1024)/5 * (h + 2)).toString(),'"'
          ' transform="translate(',node.x.toString(),',',node.y.toString(),') scale(',node.scale,',',node.scale,')" fill="black" />'
      );  
    }
    svgPart = string(abi.encodePacked(
      '<mask id="',tag,'_mask">'
      '<rect x="0" y="0" width="100%" height="100%" fill="white"/>',
      parts.packed(),
      '</mask>\n'
      '<rect id="',tag,'_stencil" mask="url(#', tag ,'_mask)" '
        'x="0" y="0" width="100%" height="100%" />\n'));
    svgPart = string(abi.encodePacked(svgPart,
      '<g id="',tag,'" >\n'
      '<use href="#', tag ,'_stencil" fill="#', props.scheme[1], '" />\n'
      '<use href="#', tag ,'_stencil" fill="#', props.scheme[2], '" transform="rotate(0 512 512)"/>\n'
      '<use href="#', tag ,'_stencil" fill="#', props.scheme[3], '" transform="rotate(0 512 512)"/>\n'
      '<use href="#', tag ,'_stencil" fill="#', props.scheme[4], '" transform="rotate(0 512 512)"/>\n'
      '</g>\n'
    ));
  }
}
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
import "fully-on-chain.sol/SVG.sol";

/**
 * MultiplexProvider create a new asset provider from another asset provider,
 * which draws multiple assets with the same set of provider-specific properties.
 */
contract AlphabetProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using BytesArray for bytes[];
  using SVG for SVG.Element;
  using TX for string;

  ILayoutGenerator public generator;
  IColorSchemes public colorSchemes;
  IFontProvider public font;
  IAssetProvider public nouns;

  constructor(IFontProvider _font, ILayoutGenerator _generator, IColorSchemes _colorSchemes, IAssetProvider _nouns) {
    font = _font;
    generator = _generator;
    colorSchemes = _colorSchemes;
    nouns = _nouns;
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
    return ProviderInfo("stencil", "Stencil", this);
  }

  function totalSupply() external pure override returns(uint256) {
    return 0;
  }

  function processPayout(uint256 _assetId) external override payable {
    address payable payableTo = payable(owner());
    payableTo.transfer(msg.value);
    emit Payout("stencil", _assetId, payableTo, msg.value);
  }

  function generateTraits(uint256 _assetId) external view returns (string memory) {
    return colorSchemes.generateTraits(_assetId);
  }

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    Randomizer.Seed memory seed;
    string[] memory scheme;
    (seed, scheme) = colorSchemes.getColorScheme(_assetId);
    tag = string(abi.encodePacked("alphabet", _assetId.toString()));

    for (uint i=0; i<scheme.length; i++) {
      scheme[i] = string(abi.encodePacked('#', scheme[i]));      
    }

    ILayoutGenerator.Node[] memory nodes;
    (seed, nodes) = generator.generate(seed, 0 + 30 * 0x100 + 60 * 0x10000);

    SVG.Element[] memory parts = new SVG.Element[](nodes.length);
    bytes memory text = new bytes(1);
    bytes memory scrabble = bytes("AAAAAAAAABBCCDDDDEEEEEEEEEEEEFFGGGHHIIII"
                              "IIIIIJKLLLLMMNNNNNNOOOOOOPPQRRTTTTTTUUUUVVWWXYYZ");
    string memory svgNouns;
    string memory idNouns;
    (svgNouns, idNouns) = nouns.generateSVGPart(_assetId);

    for (uint i = 0; i < nodes.length; i++) {
      ILayoutGenerator.Node memory node = nodes[i];
      uint index;
      (seed, index) = seed.random(scrabble.length);
      text[0] = scrabble[index];
      uint width = font.widthOf(string(text));
      width = ((1024 - width) / 2 * node.size) / 1024;
      if (i == 15) {
        parts[i] = SVG.use(idNouns).transform(TX.translate(int(node.x), int(node.y)).scale1000(node.size));
      } else {
        parts[i] = SVG.group([
                    SVG.rect(int(node.x), int(node.y), node.size, node.size)
                      .fill(scheme[i % scheme.length]),
                    SVG.text(font, string(text))
                      .transform(TX.translate(int(node.x + width), int(node.y + node.size/10)).scale1000(node.size))]);
      }
    }
    svgPart = string(abi.encodePacked(
      svgNouns,
      SVG.group(parts).id(tag).fill("#222").svg()
    ));
  }
}
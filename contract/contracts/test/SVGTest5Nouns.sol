// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import 'randomizer.sol/Randomizer.sol';
import 'trigonometry.sol/Trigonometry.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '../packages/graphics/Path.sol';
import '../packages/graphics/SVG.sol';
import '../packages/graphics/Text.sol';
import 'hardhat/console.sol';
import 'assetprovider.sol/IAssetProvider.sol';
import '../providers/NounsAssetProvider.sol';

contract SVGTest5Nouns {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Vector for Vector.Struct;
  using Path for uint[];
  using SVG for SVG.Element;
  using TX for string;
  using Trigonometry for uint;

  NounsAssetProvider nouns;
  IAssetProvider dotNouns;

  constructor(NounsAssetProvider _nouns, IAssetProvider _dotNouns) {
    nouns = _nouns;
    dotNouns = _dotNouns;
  }

  function main() external view returns (string memory output) {
    SVG.Element[] memory samples = new SVG.Element[](16);
    SVG.Element[] memory uses = new SVG.Element[](16);

    samples[0] = SVG.rect(256, 256, 512, 512).fill('yellow').stroke('blue', 10).transform('rotate(30 512 512)');

    string memory svgPart;
    string memory svgId;
    (svgPart, svgId) = nouns.getNounsSVGPart(245);
    samples[1] = SVG.group(bytes(svgPart));
    (svgPart, svgId) = dotNouns.generateSVGPart(0);
    samples[2] = SVG.group(bytes(svgPart));
    samples[3] = SVG.use(svgId);

    for (uint i = 0; i < 4; i++) {
      int x = int(256 * (i % 4));
      int y = int(256 * (i / 4));
      string memory tag = string(abi.encodePacked('test', i.toString()));
      samples[i] = samples[i].id(tag);
      uses[i] = SVG.group([SVG.rect().fill('#c0c0c0'), SVG.use(tag)]).transform((TX.translate(x, y).scale('0.24')));
    }

    output = SVG.document('0 0 1024 1024', SVG.list(samples).svg(), SVG.list(uses).svg());
  }
}

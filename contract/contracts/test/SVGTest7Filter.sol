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
import '../packages/graphics/SVGFilter.sol';
import '../packages/graphics/Text.sol';
import '../fonts/LondrinaSolid.sol';
import 'hardhat/console.sol';

contract SVGTest7Filter {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Vector for Vector.Struct;
  using Path for uint[];
  using SVG for SVG.Element;
  using TX for string;
  using Trigonometry for uint;

  constructor() {
  }

  function main() external pure returns (string memory output) {
    SVG.Element[] memory samples = new SVG.Element[](16);
    SVG.Element[] memory uses = new SVG.Element[](16);

    samples[0] = SVG.group([SVG.rect(256, 256, 640, 640).fill('yellow'), 
                            SVG.circle(320, 320, 280).fill('red')]);
    samples[1] = SVG.group([SVGFilter.roughPaper("roughPaper"), 
                            SVG.group([SVG.rect(256, 256, 640, 640).fill('yellow'), 
                                       SVG.circle(320, 320, 280).fill('red')])
                              .filter('roughPaper')]);

    for (uint i = 0; i < 2; i++) {
      int x = int(256 * (i % 4));
      int y = int(256 * (i / 4));
      string memory tag = string(abi.encodePacked('test', i.toString()));
      samples[i] = samples[i].id(tag);
      uses[i] = SVG.group([SVG.rect().fill('#c0c0c0'), SVG.use(tag)]).transform((TX.translate(x, y).scale('0.24')));
    }

    output = SVG.document('0 0 1024 1024', SVG.list(samples).svg(), SVG.list(uses).svg());
  }
}

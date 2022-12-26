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

  constructor() {}

  function main() external pure returns (string memory output) {
    SVG.Element[] memory samples = new SVG.Element[](16);
    SVG.Element[] memory uses = new SVG.Element[](16);

    samples[0] = SVG.group([SVG.rect(256, 256, 640, 640).fill('yellow'), SVG.circle(320, 320, 280).fill('red')]);
    samples[1] = SVG.group(
      [
        SVGFilter.roughPaper('roughPaper'),
        SVG.group([SVG.rect(256, 256, 640, 640).fill('yellow'), SVG.circle(320, 320, 280).fill('red')]).filter(
          'roughPaper'
        )
      ]
    );

    samples[2] = SVG.group(
      [
        SVG.list(
          [
            SVG
              .linearGradient(
                'shine1',
                SVG.list(
                  [SVG.stop(0).stopColor('#FFF0'), SVG.stop(50).stopColor('#FFF6'), SVG.stop(100).stopColor('#FFF0')]
                )
              )
              .x1('80%')
              .x2('20%')
              .y1('0%')
              .y2('100%'),
            SVG
              .linearGradient(
                'shine2',
                SVG.list(
                  [SVG.stop(0).stopColor('#FFF0'), SVG.stop(50).stopColor('#FFF8'), SVG.stop(100).stopColor('#FFF0')]
                )
              )
              .x1('100%')
              .x2('0%')
              .y1('0%')
              .y2('100%'),
            SVG
              .linearGradient(
                'shine3',
                SVG.list(
                  [SVG.stop(0).stopColor('#FFF0'), SVG.stop(50).stopColor('#FFF6'), SVG.stop(100).stopColor('#FFF0')]
                )
              )
              .x1('100%')
              .x2('0%')
              .y1('20%')
              .y2('80%'),
            SVG
              .linearGradient(
                'shine4',
                SVG.list(
                  [
                    SVG.stop(0).stopColor('#FFF0'),
                    SVG.stop(20).stopColor('#FFF7'),
                    SVG.list(
                      [
                        SVG.stop(50).stopColor('#FFF3'),
                        SVG.stop(70).stopColor('#FFF5'),
                        SVG.stop(100).stopColor('#FFF0')
                      ]
                    )
                  ]
                )
              )
              .x1('20%')
              .x2('80%')
              .y1('0%')
              .y2('100%')
          ]
        ),
        SVG.group(
          [
            SVG.rect().fill('#444'),
            SVG.rect().fillRef('shine1'),
            SVG.rect().fillRef('shine2'),
            SVG.rect().fillRef('shine3')
          ]
        )
      ]
    );

    samples[3] = SVG.group(SVG.use('test2').transform('scale(.0625)').id('cell'));

    SVG.Element[] memory cells = new SVG.Element[](16);
    for (uint i = 0; i < 16; i++) {
      cells[i] = SVG.use('cell').transform(TX.translate(int(i * 64), 0));
    }
    samples[4] = SVG.group(SVG.group(cells).id('cell16'));

    for (uint i = 0; i < 16; i++) {
      cells[i] = SVG.use('cell16').transform(TX.translate(0, int(i * 64)));
    }
    samples[5] = SVG.group(cells);

    samples[6] = SVG.group([SVG.use('test5'), SVG.rect().fillRef('shine4')]);

    for (uint i = 0; i < 7; i++) {
      int x = int(256 * (i % 4));
      int y = int(256 * (i / 4));
      string memory tag = string(abi.encodePacked('test', i.toString()));
      samples[i] = samples[i].id(tag);
      uses[i] = SVG.group([SVG.rect().fill('#c0c0c0'), SVG.use(tag)]).transform((TX.translate(x, y).scale('0.24')));
    }

    output = SVG.document('0 0 1024 1024', SVG.list(samples).svg(), SVG.list(uses).svg());
  }
}

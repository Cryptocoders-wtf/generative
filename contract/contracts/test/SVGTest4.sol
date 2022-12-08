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
import '../fonts/LondrinaSolid.sol';
import 'hardhat/console.sol';
import 'assetprovider.sol/IAssetProvider.sol';
import '../interfaces/ILayoutGenerator.sol';
import '../libs/MatrixGenerator.sol';
import '../libs/ColorSchemes.sol';

contract SVGTest4 {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Vector for Vector.Struct;
  using Path for uint[];
  using SVG for SVG.Element;
  using TX for string;
  using Trigonometry for uint;

  bytes constant twitter =
    '\x4d\x80\x94\xd4\x05\x63\x01\x55\x09\x01\x55\x12\x01\x55\x1b\x00\x65\x14\x2e\x74\x51\xaf\x72\x51\x76\x50\x00\x63\x40\x8f\x00\x45\x20\xe0\x34\xc0\xa3\x54\x10\x02\x55\x21\x03\x55\x32\x03\x55\x5e\x00\x55\xb9\xe1\x64\x03\xa7\x44\xa7\xfe\x44\x59\xc4\x44\x3d\x6f\x54\x1f\x06\x55\x3f\x05\x55\x5e\xfc\x44\x9f\xec\x44\x59\x97\x44\x59\x34\x04\x76\xfd\x04\x63\x1d\x55\x10\x3d\x55\x19\x5f\x55\x1a\x43\x50\x30\x05\x56\x14\x8c\x55\x4b\x2c\x05\x63\x6a\x55\x82\x06\x56\xd1\xae\x56\xda\xef\x44\xb8\x06\x45\x6c\x3c\x45\x39\x54\x45\xb1\xd8\x45\xb5\x27\x56\x09\x2f\x45\xf7\x5b\x45\xe6\x84\x45\xcd\xf0\x54\x30\xd0\x54\x59\xa4\x54\x73\x29\x45\xfb\x52\x45\xf0\x78\x45\xdf\xe4\x54\x2a\xc1\x54\x4e\x98\x54\x6c\x7a\x00';
  IFontProvider public immutable font;
  ILayoutGenerator public generator;
  IColorSchemes public colorSchemes;

  constructor() {
    font = new LondrinaSolid(address(0x0));
    generator = new MatrixGenerator();
    colorSchemes = new ColorSchemes();
  }

  function doubles(Randomizer.Seed memory _seed, uint _max) internal pure returns (Randomizer.Seed memory, uint) {
    uint v1;
    uint v2;
    (_seed, v1) = _seed.random(_max);
    (_seed, v2) = _seed.random(_max);
    return (_seed, v1 + v2);
  }

  struct Stackframe {
    uint degree;
    uint distance;
    uint radius;
    uint rotate;
    int x;
    int y;
  }

  function main() external view returns (string memory output) {
    SVG.Element[] memory samples = new SVG.Element[](16);
    SVG.Element[] memory uses = new SVG.Element[](16);

    samples[0] = SVG.text(
      font,
      [
        'Elon Musk',
        '@elonmusk',
        '',
        'I will not let you down,',
        'no matter what it takes',
        '',
        '11:46 AM Oct 19, 2022'
      ],
      1024
    );

    samples[1] = SVG.group(
      [
        SVG.path(Path.decode(twitter)).fill('#1d9bf0').transform(TX.translate(int(819), 0).scale1000(200)),
        SVG
          .group(
            [
              SVG.text(font, 'Elon Musk'),
              SVG.text(font, '@elonmusk').fill('grey').transform(TX.translate(int(0), int(1024)))
            ]
          )
          .transform(TX.scale1000(100)),
        SVG.text(font, Text.split('I will not let you down,\nno matter what it takes', 0x0a), 1024).transform(
          TX.translate(0, int(384))
        ),
        SVG.text(font, '11:46 AM Oct 19, 2022').fill('grey').transform(TX.translate(0, int(921)).scale1000(100))
      ]
    );

    samples[2] = SVG.group(
      [SVG.pattern('pattern2', '0 0 100 100', '10%', '10%', SVG.circle(50, 50, 50)), SVG.rect().fillRef('pattern2')]
    );

    {
      Randomizer.Seed memory seed;
      string[] memory scheme;
      (seed, scheme) = colorSchemes.getColorScheme(0);
      for (uint i = 0; i < scheme.length; i++) {
        scheme[i] = string(abi.encodePacked('#', scheme[i]));
      }

      ILayoutGenerator.Node[] memory nodes;
      (seed, nodes) = generator.generate(seed, 0 + 30 * 0x100 + 60 * 0x10000);

      SVG.Element[] memory parts = new SVG.Element[](nodes.length);
      bytes memory text = new bytes(1);
      bytes memory scrabble = bytes(
        'AAAAAAAAAB'
        'BCCDDDDEEE'
        'EEEEEEEEEF'
        'FGGGHHIIII'
        'IIIIIJKLLL'
        'LMMNNNNNNO'
        'OOOOOPPQRR'
        'TTTTTTUUUU'
        'VVWWXYYZ'
      );
      for (uint i = 0; i < nodes.length; i++) {
        ILayoutGenerator.Node memory node = nodes[i];
        uint index;
        (seed, index) = seed.random(scrabble.length);
        text[0] = scrabble[index];
        uint width = font.widthOf(string(text));
        width = (((1024 - width) / 2) * node.size) / 1024;
        parts[i] = SVG.group(
          [
            SVG.rect(int(node.x), int(node.y), node.size, node.size).fill(scheme[i % scheme.length]),
            SVG.text(font, string(text)).transform(
              TX.translate(int(node.x + width), int(node.y + node.size / 10)).scale1000(node.size)
            )
          ]
        );
      }
      samples[3] = SVG.group(parts);
    }

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

// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import 'randomizer.sol/Randomizer.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '../packages/graphics/Path.sol';
import '../packages/graphics/SVG.sol';
import 'hardhat/console.sol';

contract SVGTest6Dot {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Vector for Vector.Struct;
  using Path for uint[];
  using SVG for SVG.Element;
  using TX for string;

  function main() external pure returns (string memory output) {
    SVG.Element[] memory samples = new SVG.Element[](16);
    SVG.Element[] memory uses = new SVG.Element[](16);

    samples[0] = SVG.group(
      SVG.group([SVG.circle(16, 16, 16), SVG.circle(48, 16, 16), SVG.circle(80, 16, 16), SVG.circle(112, 16, 16)]).id(
        'dot32_4'
      )
    );

    samples[1] = SVG.group(
      SVG
        .group(
          [
            SVG.use('dot32_4'),
            SVG.use('dot32_4').transform('translate(128 0)'),
            SVG.use('dot32_4').transform('translate(256 0)'),
            SVG.use('dot32_4').transform('translate(384 0)'),
            SVG.use('dot32_4').transform('translate(512 0)'),
            SVG.use('dot32_4').transform('translate(640 0)'),
            SVG.use('dot32_4').transform('translate(768 0)'),
            SVG.use('dot32_4').transform('translate(896 0)')
          ]
        )
        .id('dot32_32')
    );

    samples[2] = SVG.group(
      SVG
        .group(
          [
            SVG.use('dot32_32'),
            SVG.use('dot32_32').transform('translate(0 32)'),
            SVG.use('dot32_32').transform('translate(0 64)'),
            SVG.use('dot32_32').transform('translate(0 96)')
          ]
        )
        .id('dot32_128')
    );

    samples[3] = SVG.group(
      SVG
        .group(
          [
            SVG.use('dot32_128'),
            SVG.use('dot32_128').transform('translate(0 128)'),
            SVG.use('dot32_128').transform('translate(0 256)'),
            SVG.use('dot32_128').transform('translate(0 384)'),
            SVG.use('dot32_128').transform('translate(0 512)'),
            SVG.use('dot32_128').transform('translate(0 640)'),
            SVG.use('dot32_128').transform('translate(0 768)'),
            SVG.use('dot32_128').transform('translate(0 896)')
          ]
        )
        .id('dot32_1024')
    );

    samples[4] = SVG.circle(512, 512, 300).fill('blue');

    samples[5] = SVG.group([SVG.rect(256, 256, 640, 640).fill('yellow'), SVG.circle(320, 320, 280)]);

    samples[6] = SVG.use('test5').fill('green').transform('translate(200 200) scale(0.6) rotate(45 512 512) ');

    samples[7] = SVG.group(
      [
        SVG.use('test5').fill('green').transform('scale(0.5)'),
        SVG.use('test5').fill('red').transform('translate(512 0) scale(0.5)'),
        SVG.use('test5').fill('blue').transform('translate(0 512) scale(0.5)'),
        SVG.use('test5').fill('grey').transform('translate(512 512) scale(0.5)')
      ]
    );

    {
      uint count = 12;
      int radius = 511;
      Vector.Struct memory center = Vector.vector(512, 512);
      uint[] memory points = new uint[](count * 2);
      for (uint i = 0; i < count * 2; i += 2) {
        int angle = (Vector.PI2 * int(i)) / int(count) / 2;
        Vector.Struct memory vector = Vector.vectorWithAngle(angle, radius);
        points[i] = Path.roundedCorner(vector.add(center));
        points[i + 1] = Path.sharpCorner(vector.div(2).rotate(Vector.PI2 / int(count) / 2).add(center));
      }
      samples[8] = SVG.path(points.closedPath());
    }

    samples[9] = SVG.group(
      [SVG.stencil(SVG.use('test8')).id('test8_mask'), SVG.rect().fill('yellow').mask('test8_mask')]
    );

    samples[10] = SVG.group([SVG.stencil(SVG.use('test8')).id('test10_mask'), SVG.use('test7').mask('test10_mask')]);

    samples[11] = SVG.group([SVG.mask('test11_mask', SVG.use('test8')), SVG.use('test7').mask('test11_mask')]);

    {
      uint count = 12;
      int radius = 511;
      Vector.Struct memory center = Vector.vector(512, 512);
      uint[] memory points = new uint[](count * 2);
      for (uint i = 0; i < count * 2; i += 2) {
        int angle = (Vector.PI2 * int(i)) / int(count) / 2;
        Vector.Struct memory vector = Vector.vectorWithAngle(angle, radius);
        points[i] = Path.roundedCorner(vector.add(center));
        points[i + 1] = Path.sharpCorner(vector.div(2).rotate(Vector.PI2 / int(count) / 2).add(center));
      }
      samples[12] = SVG.path(points.closedPath());
    }

    // 1073 bytes
    bytes
      memory bitcoin = 'M2947.77 1754.38c40.72,-272.26 -166.56,-418.61 -450,-516.24l91.95 -368.8 -224.5 -55.94 -89.51 359.09c-59.02,-14.72 -119.63,-28.59 -179.87,-42.34l90.16 -361.46 -224.36 -55.94 -92 368.68c-48.84,-11.12 -96.81,-22.11 -143.35,-33.69l0.26 -1.16 -309.59 -77.31 -59.72 239.78c0,0 166.56,38.18 163.05,40.53 90.91,22.69 107.35,82.87 104.62,130.57l-104.74 420.15c6.26,1.59 14.38,3.89 23.34,7.49 -7.49,-1.86 -15.46,-3.89 -23.73,-5.87l-146.81 588.57c-11.11,27.62 -39.31,69.07 -102.87,53.33 2.25,3.26 -163.17,-40.72 -163.17,-40.72l-111.46 256.98 292.15 72.83c54.35,13.63 107.61,27.89 160.06,41.3l-92.9 373.03 224.24 55.94 92 -369.07c61.26,16.63 120.71,31.97 178.91,46.43l-91.69 367.33 224.51 55.94 92.89 -372.33c382.82,72.45 670.67,43.24 791.83,-303.02 97.63,-278.78 -4.86,-439.58 -206.26,-544.44 146.69,-33.83 257.18,-130.31 286.64,-329.61l-0.07 -0.05zm-512.93 719.26c-69.38,278.78 -538.76,128.08 -690.94,90.29l123.28 -494.2c152.17,37.99 640.17,113.17 567.67,403.91zm69.43 -723.3c-63.29,253.58 -453.96,124.75 -580.69,93.16l111.77 -448.21c126.73,31.59 534.85,90.55 468.94,355.05l-0.02 0z';
    samples[13] = SVG.path(bitcoin).fill('#F7931A').transform('scale(0.25)');

    // 287 bytes
    bytes
      memory fontP = '\x4d\x70\xe1\xb7\x06\x63\x0a\x45\xbc\xd6\x44\x97\x90\x44\x7f\x6c\x50\x17\xa4\x44\xc8\xf2\x44\xea\x5a\x05\x63\xf1\x44\xfc\xe2\x44\xf9\xd3\x44\xf5\x6c\x50\x17\xa6\x44\xc8\xf2\x44\xe9\x5c\x05\x63\xf4\x44\xfd\xe8\x44\xfa\xdc\x44\xf8\x6c\x50\x00\x00\x45\xb3\xed\x44\xf1\x3c\x05\x63\x00\x55\x00\x2a\x55\x0a\x29\x55\x0a\x17\x55\x06\x1b\x55\x15\x1a\x55\x21\x6c\x40\xe6\x69\x05\x63\x02\x55\x00\x04\x55\x01\x06\x55\x02\xfe\x54\x00\xfc\x44\xff\xfa\x44\xff\x6c\x40\xdb\x93\x05\x63\xfd\x54\x07\xf6\x54\x11\xe6\x54\x0d\x01\x55\x01\xd7\x44\xf6\xd7\x44\xf6\x6c\x40\xe4\x40\x55\x49\x12\x05\x63\x0e\x55\x03\x1b\x55\x07\x28\x55\x0a\x6c\x40\xe9\x5d\x55\x38\x0e\x55\x17\xa4\x04\x63\x0f\x55\x04\x1e\x55\x08\x2d\x55\x0c\x6c\x40\xe9\x5c\x55\x38\x0e\x55\x17\xa3\x04\x63\x60\x55\x12\xa8\x55\x0b\xc6\x45\xb4\x18\x45\xba\xff\x44\x92\xcc\x44\x78\x25\x45\xf8\x40\x45\xdf\x48\x45\xae\x6c\x50\x00\x00\x05\x7a\x6d\x40\x80\xb4\x05\x63\xef\x54\x46\x79\x54\x20\x53\x54\x17\x6c\x50\x1f\x84\x04\x63\x26\x55\x09\xa0\x55\x1c\x8e\x55\x65\x7a\x00\x6d\x11\x45\x4b\x63\x40\xf0\x3f\x45\x8f\x1f\x45\x6f\x17\x05\x6c\x1c\x45\x90\x63\x50\x20\x08\x55\x86\x17\x55\x75\x59\x05\x6c\x00\x55\x00\x7a\x00';
    samples[14] = SVG.path(Path.decode(fontP)).fill('#F7931A');

    samples[15] = SVG.group(
      [
        SVG.mask(
          'test15_mask',
          SVG.group(
            [
              SVG.group(
                [
                  SVG.rect(256, 362, 300, 300),
                  SVG.rect(662, 362, 300, 300),
                  SVG.rect(112, 462, 800, 50),
                  SVG.rect(112, 462, 50, 150)
                ]
              ),
              SVG.group([SVG.rect(312, 412, 100, 200), SVG.rect(712, 412, 100, 200)]).fill('black')
            ]
          )
        ),
        SVG.rect().fill('red').mask('test15_mask')
      ]
    );

    for (uint i = 0; i < 16; i++) {
      int x = int(256 * (i % 4));
      int y = int(256 * (i / 4));
      string memory tag = string(abi.encodePacked('test', i.toString()));
      samples[i] = samples[i].id(tag);
      uses[i] = SVG.group([SVG.rect().fill('#c0c0c0'), SVG.use(tag)]).transform((TX.translate(x, y).scale('0.24')));
    }

    output = SVG.document('0 0 1024 1024', SVG.list(samples).svg(), SVG.list(uses).svg());
  }
}

// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import "randomizer.sol/Randomizer.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../packages/graphics/Path.sol";
import "../packages/graphics/SVG.sol";
import "hardhat/console.sol";

contract SVGTest {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Vector for Vector.Struct;
  using Path for uint[];
  using SVG for SVG.Element;

  function main() external pure returns(string memory output) {
    SVG.Element[] memory samples = new SVG.Element[](16);
    SVG.Element[] memory uses = new SVG.Element[](16);

    samples[0] = SVG.rect(256, 256, 512, 512);

    samples[1] = SVG.rect(256, 256, 512, 512)
                      .fill("yellow");

    samples[2] = SVG.rect(256, 256, 512, 512)
                      .fill("yellow")
                      .stroke("blue", 10);

    samples[3] = SVG.rect(256, 256, 512, 512)
                      .fill("yellow")
                      .stroke("blue", 10)
                      .transform("rotate(30 512 512)");

    samples[4] = SVG.circle(512, 512, 300)
                      .fill("blue");

    samples[5] = SVG.group([
                      SVG.rect(256, 256, 640, 640).fill("yellow"),
                      SVG.circle(320, 320, 280)
                    ]);

    samples[6] = SVG.use("test5")
                      .fill("green")
                      .transform("translate(200 200) scale(0.6) rotate(45 512 512) ");

    samples[7] = SVG.group([
                      SVG.use("test5")
                        .fill("green")                      
                        .transform("scale(0.5)"),
                      SVG.use("test5")
                        .fill("red")                      
                        .transform("translate(512 0) scale(0.5)"),
                      SVG.use("test5")
                        .fill("blue")                      
                        .transform("translate(0 512) scale(0.5)"),
                      SVG.use("test5")
                        .fill("grey")                      
                        .transform("translate(512 512) scale(0.5)")
                    ]);

    {
      uint count = 12;
      int radius = 511;
      Vector.Struct memory center = Vector.vector(512, 512);
      uint[] memory points = new uint[](count * 2);    
      for (uint i = 0; i < count * 2; i += 2) {
        int angle = Vector.PI2 * int(i) / int(count) / 2;
        Vector.Struct memory vector = Vector.vectorWithAngle(angle, radius);
        points[i] = Path.roundedCorner(vector.add(center));
        points[i+1] = Path.sharpCorner(vector.div(2).rotate(Vector.PI2 / int(count) / 2).add(center));
      }
      samples[8] = SVG.path(points.closedPath());
    }

    samples[9] = SVG.group([
                      SVG.stencil(
                        SVG.use("test8")
                      ).id("test8_mask"),                      
                      SVG.rect()
                        .fill("yellow")                      
                        .mask("test8_mask")
                    ]);

    samples[10] = SVG.group([
                      SVG.stencil(
                        SVG.use("test8")
                      ).id("test10_mask"),
                      SVG.use("test7")
                        .mask("test10_mask")
                    ]);

    samples[11] = SVG.group([
                      SVG.mask(
                        SVG.use("test8")
                      ).id("test11_mask"),                      
                      SVG.use("test7")
                        .mask("test11_mask")
                    ]);

    {
      uint count = 12;
      int radius = 511;
      Vector.Struct memory center = Vector.vector(512, 512);
      uint[] memory points = new uint[](count * 2);    
      for (uint i = 0; i < count * 2; i += 2) {
        int angle = Vector.PI2 * int(i) / int(count) / 2;
        Vector.Struct memory vector = Vector.vectorWithAngle(angle, radius);
        points[i] = Path.roundedCorner(vector.add(center));
        points[i+1] = Path.sharpCorner(vector.div(2).rotate(Vector.PI2 / int(count) / 2).add(center));
      }
      samples[12] = SVG.path(points.closedPath());
    }

    bytes memory bitcoin = "M 737 439 c 10 -68 -42 -105 -112 -129 l 23 -92 -56 -14 -22 90 c -15 -4 -30 -7 -45 -11 l 23 -90 -56 -14 -23 92 c -12 -3 -24 -6 -36 -8 l 0 0 -77 -19 -15 60 c 0 0 42 10 41 10 23 6 27 21 26 33 l -26 105 c 2 0 4 1 6 2 -2 0 -4 -1 -6 -1 l -37 147 c -3 7 -10 17 -26 13 1 1 -41 -10 -41 -10 l -28 64 73 18 c 14 3 27 7 40 10 l -23 93 56 14 23 -92 c 15 4 30 8 45 12 l -23 92 56 14 23 -93 c 96 18 168 11 198 -76 24 -70 -1 -110 -52 -136 37 -8 64 -33 72 -82 l 0 0 zm -128 180 c -17 70 -135 32 -173 23 l 31 -124 c 38 9 160 28 142 101 zm 17 -181 c -16 63 -113 31 -145 23 l 28 -112 c 32 8 134 23 117 89 l 0 0 z";
    samples[13] = SVG.path(bytes(bitcoin)).fill("#F7931A");
    samples[14] = SVG.rect(256, 256, 512, 512);

    samples[15] = SVG.group([
                      SVG.mask(
                        SVG.group([
                          SVG.group([
                            SVG.rect(256, 362, 300, 300),
                            SVG.rect(662, 362, 300, 300),
                            SVG.rect(112, 462, 800, 50),
                            SVG.rect(112, 462, 50, 150)
                          ]),
                          SVG.group([
                            SVG.rect(312, 412, 100, 200),
                            SVG.rect(712, 412, 100, 200)
                          ]).fill("black")
                        ])
                      ).id("test15_mask"),                      
                      SVG.rect()
                        .fill("red")                      
                        .mask("test15_mask")
                      ]);

    for (uint i=0; i<16; i++) {
      uint x = 256 * (i % 4);
      uint y = 256 * (i / 4);
      string memory tag = string(abi.encodePacked("test", i.toString()));
      samples[i] = samples[i].id(tag);
      uses[i] = SVG.group([
        SVG.rect(16,16,992,992).fill("#c0c0c0"), 
        SVG.use(tag)
      ]).transform(string(abi.encodePacked('translate(',x.toString(),' ', y.toString(), ') scale(0.25)')));
    }

    output = SVG.document(
      "0 0 1024 1024",
      SVG.list(samples).svg(),
      SVG.list(uses).svg()
    );
  }
}
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

    string memory bitcoin = "M2947.77 1754.38c40.72,-272.26 -166.56,-418.61 -450,-516.24l91.95 -368.8 -224.5 -55.94 -89.51 359.09c-59.02,-14.72 -119.63,-28.59 -179.87,-42.34l90.16 -361.46 -224.36 -55.94 -92 368.68c-48.84,-11.12 -96.81,-22.11 -143.35,-33.69l0.26 -1.16 -309.59 -77.31 -59.72 239.78c0,0 166.56,38.18 163.05,40.53 90.91,22.69 107.35,82.87 104.62,130.57l-104.74 420.15c6.26,1.59 14.38,3.89 23.34,7.49 -7.49,-1.86 -15.46,-3.89 -23.73,-5.87l-146.81 588.57c-11.11,27.62 -39.31,69.07 -102.87,53.33 2.25,3.26 -163.17,-40.72 -163.17,-40.72l-111.46 256.98 292.15 72.83c54.35,13.63 107.61,27.89 160.06,41.3l-92.9 373.03 224.24 55.94 92 -369.07c61.26,16.63 120.71,31.97 178.91,46.43l-91.69 367.33 224.51 55.94 92.89 -372.33c382.82,72.45 670.67,43.24 791.83,-303.02 97.63,-278.78 -4.86,-439.58 -206.26,-544.44 146.69,-33.83 257.18,-130.31 286.64,-329.61l-0.07 -0.05zm-512.93 719.26c-69.38,278.78 -538.76,128.08 -690.94,90.29l123.28 -494.2c152.17,37.99 640.17,113.17 567.67,403.91zm69.43 -723.3c-63.29,253.58 -453.96,124.75 -580.69,93.16l111.77 -448.21c126.73,31.59 534.85,90.55 468.94,355.05l-0.02 0z";
    samples[13] = SVG.path(bytes(bitcoin)).transform("scale(0.25)");
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
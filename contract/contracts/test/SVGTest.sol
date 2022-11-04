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
  using SVG for SVG.Tag;

  function main() external pure returns(string memory output) {
    SVG.Tag[] memory samples = new SVG.Tag[](16);
    SVG.Tag[] memory uses = new SVG.Tag[](16);

    samples[0] = SVG.rect(256, 256, 512, 512)
                      .id("test0");

    samples[1] = SVG.rect(256, 256, 512, 512)
                      .fill("yellow")
                      .id("test1");

    samples[2] = SVG.rect(256, 256, 512, 512)
                      .fill("yellow")
                      .stroke("blue", 10)
                      .id("test2");

    samples[3] = SVG.rect(256, 256, 512, 512)
                      .fill("yellow")
                      .stroke("blue", 10)
                      .transform("rotate(30 512 512)")
                      .id("test3");

    samples[4] = SVG.circle(512, 512, 300)
                      .fill("blue")
                      .id("test4");

    samples[5] = SVG.group([
                      SVG.rect(256, 256, 640, 640).fill("yellow"),
                      SVG.circle(320, 320, 280)
                    ]).id("test5");

    samples[6] = SVG.use("test5")
                      .fill("green")
                      .transform("translate(200 200) scale(0.6) rotate(45 512 512) ")
                      .id("test6");

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
                    ]).id("test7");

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
      samples[8] = SVG.path(points.closedPath()).id("test8");
    }

    samples[9] = SVG.group([
                      SVG.stencil(
                        SVG.use("test8")
                      ).id("test8_mask"),                      
                      SVG.rect()
                        .fill("yellow")                      
                        .mask("test8_mask")
                    ]).id("test9");

    samples[10] = SVG.group([
                      SVG.stencil(
                        SVG.use("test8")
                      ).id("test10_mask"),
                      SVG.use("test7")
                        .mask("test10_mask")
                    ]).id("test10");

    samples[11] = SVG.group([
                      SVG.mask(
                        SVG.use("test8")
                      ).id("test11_mask"),                      
                      SVG.use("test7")
                        .mask("test11_mask")
                    ]).id("test11");

    for (uint i=0; i<16; i++) {
      uint x = 256 * (i % 4);
      uint y = 256 * (i / 4);
      uses[i] = SVG.group([
        SVG.rect(16,16,992,992).fill("#c0c0c0"), 
        SVG.use(string(abi.encodePacked("test", i.toString())))
      ]).transform(string(abi.encodePacked('translate(',x.toString(),' ', y.toString(), ') scale(0.25)')));
    }

    output = string(SVG.document(
      "0 0 1024 1024",
      SVG.packed(samples),
      SVG.packed(uses)
    ));
  }
}
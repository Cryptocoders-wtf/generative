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
                      SVG.rect(256, 256, 512, 512).fill("yellow"),
                      SVG.circle(360, 360, 200)
                    ]).id("test5");

    samples[6] = SVG.use("test5")
                      .fill("green")
                      .transform("rotate(40 512 512)")
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
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
import "./LondrinaSolid.sol";
import "hardhat/console.sol";

contract SVGTest2 {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Vector for Vector.Struct;
  using Path for uint[];
  using SVG for SVG.Element;

  IFontProvider immutable public font;

  constructor() {
    font = new LondrinaSolid();
  }

  function main() external view returns(string memory output) {
    SVG.Element[] memory samples = new SVG.Element[](16);
    SVG.Element[] memory uses = new SVG.Element[](16);

    samples[0] = SVG.group([
      SVG.linearGradient("gradient1", SVG.list([
        SVG.stop(0).stopColor("red"),
        SVG.stop(100).stopColor("yellow")
      ])).x1("0%").x2("100%"),
      SVG.rect(256, 256, 512, 512)
        .fillRef("gradient1")
    ]);

    samples[1] = SVG.group([
      SVG.radialGradient("gradient2", SVG.list([
        SVG.stop(0).stopColor("red"),
        SVG.stop(100).stopColor("yellow")
      ])),
      SVG.ellipse(512, 512, 512, 256)
        .fillRef("gradient2")
    ]);

    samples[2] = SVG.group([
      SVG.filter("filter1", 
        SVG.feGaussianBlur("SourceGraphic", "20")
      ),
      SVG.ellipse(512, 512, 400, 256)
        .fill("blue")
        .filter("filter1")
    ]);

    samples[3] = SVG.group([
      SVG.filter("filter3", SVG.list([ 
        SVG.feOffset("SourceAlpha", "24", "32").result("offOut"),
        SVG.feGaussianBlur("offOut", "16").result("bluOut"),
        SVG.feBlend("SourceGraphic", "bluOut", "normal")
      ])),
      SVG.ellipse(512, 512, 400, 256)
        .fill("red")
        .filter("filter3")
    ]);

    samples[4] = SVG.path(Path.decode(font.pathOf("x")));
    samples[5] = SVG.path(Path.decode(font.pathOf("y")));
    samples[6] = SVG.path(Path.decode(font.pathOf("z")));

    for (uint i=0; i<7; i++) {
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


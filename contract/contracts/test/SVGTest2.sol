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
  using TX for string;

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

    uint width = SVG.textWidth(font, "0123456");
    samples[4] = SVG.text(font, "pNouns")
                    .fill("#224455")
                    .transform(TX.scale1000(1000 * 1024 / width));

    samples[5] = SVG.group([
      SVG.text(font, "Hello"),
      SVG.text(font, "Nouns").transform('translate(0 1024)')
    ]).transform('scale(0.4)');

    uint baseline = font.baseline();
    width = SVG.textWidth(font, "Hello");
    samples[6] = SVG.group([
      SVG.text(font, "Hello"),
      SVG.text(font, "Nouns")
        .transform(TX.translate(width, baseline/2).scale("0.5")) 
    ]).transform('scale(0.3)');

    width = SVG.textWidth(font, "0123456789&@():,$!%.?;#/");
    samples[7] = SVG.group([
              SVG.text(font, "0123456789&@():,$!%.?;#/"),
              SVG.text(font, "ABCDEFGHIJKLMNOPQRXYZ").transform('translate(0 1024)'),
              SVG.text(font, "abcdefghijklmnopqrxyz").transform('translate(0 2048)')
                  ]).fill("#224455")
                    .transform(TX.translate(0,256).scale1000(1000 * 1024 / width));

    // 1588750686006947840
    samples[8] = SVG.text(font, [
        "Elon Musk",
        "@elonmusk",
        "",
        "Trash me all day, but it'll cost $8"
      ], 1024);

    for (uint i=0; i<9; i++) {
      uint x = 256 * (i % 4);
      uint y = 256 * (i / 4);
      string memory tag = string(abi.encodePacked("test", i.toString()));
      samples[i] = samples[i].id(tag);
      uses[i] = SVG.group([
        SVG.rect().fill("#c0c0c0"), 
        SVG.use(tag)
      ]).transform((TX.translate(x, y).scale("0.24"))); 
    }

    output = SVG.document(
      "0 0 1024 1024",
      SVG.list(samples).svg(),
      SVG.list(uses).svg()
    );
  }
}


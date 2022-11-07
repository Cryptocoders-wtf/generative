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

contract SVGTest2 {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Vector for Vector.Struct;
  using Path for uint[];
  using SVG for SVG.Element;

  bytes constant font_i = "\x4d\x50\x10\xf8\x05\x73\xf7\x54\xf9\xfe\x64\x49\xfd\x54\xd5\xfa\x54\xe7\x63\x50\x14\xfa\x54\x40\xf7\x54\x72\xfb\x04\x73\x3b\x45\xfe\x44\x45\xf5\x63\x50\x00\x00\x55\x01\xbb\x53\x02\x92\x03\x73\x01\x45\x57\x01\x45\x57\x63\x50\x00\x00\x45\xa7\xf4\x44\x4f\xf7\x04\x5a\x4d\x50\x0b\x10\x05\x73\x01\x55\x62\x03\x55\x75\x02\x55\x24\x01\x55\x2b\x63\x50\x00\x00\x55\x5b\xff\x54\x7b\x02\x05\x73\x31\x55\x06\x37\x45\xfd\x63\x50\x00\x00\x45\xfa\x74\x44\xfb\x65\x54\x00\x00\x45\x6c\xfb\x44\x4d\xfb\x04\x5a";
  bytes constant font_j = "\x4d\x50\xb6\xfd\x05\x73\xfe\x64\xe1\xfc\x74\x06\x08\x55\x2c\xd6\x54\x3e\x8e\x54\x0f\x86\x54\x0c\x63\x50\x00\x00\x45\xec\x78\x45\xff\x9c\x55\x00\x00\x55\xae\x0c\x55\xf1\xe8\x04\x73\x58\x45\xd7\x5e\x45\x73\x0b\x25\xe4\x05\x25\xbc\x63\x50\x00\x00\x45\xc7\xfc\x44\xa3\x00\x05\x73\xc4\x54\x03\xb2\x44\xff\x5a\x00\x4d\xb0\x55\x0e\x73\x50\x05\x91\x55\x04\xa0\x05\x63\x00\x55\x00\x4e\x55\x00\x66\x55\x02\x73\x50\x3c\x04\x55\x48\xf0\x04\x63\x00\x55\x00\xff\x44\x7e\xfc\x44\x72\x00\x55\x00\x62\x44\xfd\x52\x44\xfc\x5a\x00";
  bytes constant font_k = "\x4d\x50\x17\x0b\x05\x73\xfd\x74\xed\xfe\x84\x14\x63\x50\x00\x00\x55\x28\x0a\x55\x5d\x06\x05\x73\x51\x55\x00\x51\x55\x00\x63\x50\x00\x00\x55\x0d\xc7\x54\x08\x5a\x04\x6c\x55\x55\xa5\x73\x50\x4c\x08\x55\x6e\x05\x55\x5e\xfc\x54\x5e\xfc\x04\x63\x00\x55\x00\x8a\x44\x22\x41\x34\xc0\x00\x55\x00\xb0\x45\x1a\xb6\x45\x0a\x00\x55\x00\xbe\x44\xfc\x8d\x54\x01\x73\x40\xaf\xf5\x44\xaf\xf5\x04\x63\x00\x55\x00\xd7\x54\x3b\xd1\x54\x44\x73\x40\xe1\x3f\x45\xd8\x43\x05\x63\x00\x55\x00\x05\x35\xbc\x01\x35\xa0\x00\x55\x00\xa8\x44\xfd\x4f\x44\xff\x5a\x00";

  function main() external pure returns(string memory output) {
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

    samples[4] = SVG.path(Path.decode(font_i));
    samples[5] = SVG.path(Path.decode(font_j));
    samples[6] = SVG.path(Path.decode(font_k));

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


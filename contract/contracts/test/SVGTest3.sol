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
import "../packages/graphics/Text.sol";
import "../fonts/LondrinaSolid.sol";
import "hardhat/console.sol";

contract SVGTest3 {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Vector for Vector.Struct;
  using Path for uint[];
  using SVG for SVG.Element;
  using TX for string;

  bytes constant twitter = "\x4d\x80\x94\xd4\x05\x63\x01\x55\x09\x01\x55\x12\x01\x55\x1b\x00\x65\x14\x2e\x74\x51\xaf\x72\x51\x76\x50\x00\x63\x40\x8f\x00\x45\x20\xe0\x34\xc0\xa3\x54\x10\x02\x55\x21\x03\x55\x32\x03\x55\x5e\x00\x55\xb9\xe1\x64\x03\xa7\x44\xa7\xfe\x44\x59\xc4\x44\x3d\x6f\x54\x1f\x06\x55\x3f\x05\x55\x5e\xfc\x44\x9f\xec\x44\x59\x97\x44\x59\x34\x04\x76\xfd\x04\x63\x1d\x55\x10\x3d\x55\x19\x5f\x55\x1a\x43\x50\x30\x05\x56\x14\x8c\x55\x4b\x2c\x05\x63\x6a\x55\x82\x06\x56\xd1\xae\x56\xda\xef\x44\xb8\x06\x45\x6c\x3c\x45\x39\x54\x45\xb1\xd8\x45\xb5\x27\x56\x09\x2f\x45\xf7\x5b\x45\xe6\x84\x45\xcd\xf0\x54\x30\xd0\x54\x59\xa4\x54\x73\x29\x45\xfb\x52\x45\xf0\x78\x45\xdf\xe4\x54\x2a\xc1\x54\x4e\x98\x54\x6c\x7a\x00";
  IFontProvider immutable public font;

  constructor() {
    font = new LondrinaSolid();
  }

  function doubles(Randomizer.Seed memory _seed, uint _max) internal pure returns(Randomizer.Seed memory, uint) {
    uint v1;
    uint v2;
    (_seed, v1) = _seed.random(_max);
    (_seed, v2) = _seed.random(_max);
    return (_seed, v1 + v2);    
  }

  function circles(uint _assetId) internal pure returns(SVG.Element memory) {
    uint count = 12;
    SVG.Element[] memory elements = new SVG.Element[](count);
    Randomizer.Seed memory seed = Randomizer.Seed(_assetId, 0);
    for (uint i=0; i<count; i++) {
      uint cx;
      uint cy;
      uint r;
      (seed, cx) = doubles(seed, 300);
      (seed, cy) = doubles(seed, 300);
      (seed, r) = seed.randomize(100, 70);
      elements[i] = SVG.circle(int(cx + 212), int(cy + 212), int(r))
                      .opacity("0.5");
    }
    return SVG.group(elements);
  }

  function main() external view returns(string memory output) {
    SVG.Element[] memory samples = new SVG.Element[](16);
    SVG.Element[] memory uses = new SVG.Element[](16);

    uint width = SVG.textWidth(font, "pNouns");
    SVG.Element memory pnouns = SVG.text(font, "pNouns")
                    .fill("#224455")
                    .transform(TX.scale1000(1000 * 1024 / width));

    for (uint i=0; i<8; i++) {
      samples[i] = SVG.group([
        pnouns,
        circles(i).transform("translate(0,200) scale(0.8)")
      ]);
    }

    for (uint i=0; i<8; i++) {
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


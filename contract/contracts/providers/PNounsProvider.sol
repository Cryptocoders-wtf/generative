// SPDX-License-Identifier: MIT

/**
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import "assetprovider.sol/IAssetProvider.sol";
import "randomizer.sol/Randomizer.sol";
import '@openzeppelin/contracts/interfaces/IERC165.sol';
import "../packages/graphics/Path.sol";
import "../packages/graphics/SVG.sol";
import "../packages/graphics/Text.sol";
import "../packages/graphics/IFontProvider.sol";

contract PNounsPrivider is IAssetProvider, Ownable, IERC165 {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Vector for Vector.Struct;
  using Path for uint[];
  using SVG for SVG.Element;
  using TX for string;
  using Trigonometry for uint;

  IFontProvider immutable public font;
  IAssetProvider immutable public nounsProvider;
  
  constructor(IFontProvider _font, IAssetProvider _nounsProvider) {
    font = _font;
    nounsProvider = _nounsProvider;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return
      interfaceId == type(IAssetProvider).interfaceId ||
      interfaceId == type(IERC165).interfaceId;
  }

  function getOwner() external override view returns (address) {
    return owner();
  }

  function getProviderInfo() external view override returns(ProviderInfo memory) {
    return ProviderInfo("pnouns", "pNouns", this);
  }

  function totalSupply() external pure override returns(uint256) {
    return 0;
  }

  function processPayout(uint256 _assetId) external override payable {
    address payable payableTo = payable(owner());
    payableTo.transfer(msg.value);
    emit Payout("pnouns", _assetId, payableTo, msg.value);
  }

  function generateTraits(uint256 _assetId) external pure override returns (string memory traits) {
    // nothing to return
  }

  // Hack to deal with too many stack variables
  struct Stackframe {
    uint degree;
    uint distance;
    uint radius;
    uint rotate;
    int x;
    int y;
  }

  function circles(uint _assetId, string[] memory idNouns) internal pure returns(SVG.Element memory) {
    string[4] memory colors = ["red", "green", "yellow", "blue"]; 
    uint count = 10;
    SVG.Element[] memory elements = new SVG.Element[](count);
    Randomizer.Seed memory seed = Randomizer.Seed(_assetId, 0);

    for (uint i=0; i<count; i++) {
      Stackframe memory stack;
      (seed, stack.degree) = seed.random(0x4000);
      (seed, stack.distance) = seed.random(480);
      (seed, stack.radius) = seed.randomize(150, 70);
      (seed, stack.rotate) = seed.random(360);
      stack.distance = stack.distance / (stack.radius / 100 + 1);
      stack.x = 512 + stack.degree.cos() * int(stack.distance) / Vector.ONE;
      stack.y = 512 + stack.degree.sin() * int(stack.distance) / Vector.ONE;
      elements[i] = SVG.group([
                      SVG.use(idNouns[i % idNouns.length])
                        .transform(TX.translate(uint(stack.x)-stack.radius, uint(stack.y)-stack.radius)
                                    .scale1000(1000 * stack.radius / 512)
                                    .rotate(string(abi.encodePacked(stack.rotate.toString(), ",512,512")))),
                      SVG.circle(stack.x, 
                                 stack.y, int(stack.radius + stack.radius/10))
                        .fill(colors[i % 4])
                        .opacity("0.333")
                    ]);
    }
    return SVG.group(elements);
  }
  
  function generateSVGPart(uint256 _assetId) public view override returns(string memory svgPart, string memory tag) {
    tag = string(abi.encodePacked("circles", _assetId.toString()));

    uint width = SVG.textWidth(font, "pNouns");
    SVG.Element memory pnouns = SVG.text(font, "pNouns")
                    .fill("#224455")
                    .transform(TX.scale1000(1000 * 1024 / width));

    string[] memory idNouns = new string[](3);
    SVG.Element[] memory svgNouns = new SVG.Element[](3);
    for (uint i=0; i<idNouns.length; i++) {
      string memory svg;
      (svg, idNouns[i]) = nounsProvider.generateSVGPart(i + _assetId);
      svgNouns[i] = SVG.item(bytes(svg));
    }

    svgPart = string(SVG.group([
      SVG.list(svgNouns),
      circles(_assetId, idNouns).transform("translate(102,204) scale(0.8)"),
      pnouns
    ]).id(tag).svg());
  }

  function generateSVGDocument(uint256 _assetId) external view returns(string memory document) {
    string memory svgPart;
    string memory tag;
    (svgPart, tag) = generateSVGPart(_assetId);
    document = SVG.document(
      "0 0 1024 1024",
      bytes(svgPart),
      SVG.use(tag).svg()
    );
  }
}
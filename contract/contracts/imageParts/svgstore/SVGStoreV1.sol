pragma solidity ^0.8.6;

import '../../packages/graphics/Path.sol';
import '../../packages/graphics/SVG.sol';

import '../interfaces/ISVGStoreV1.sol';

contract SVGStoreV1 is ISVGStoreV1 {
  using SVG for SVG.Element;

  uint256 private nextPartIndex = 1;
  mapping(uint256 => Asset) private partsList;

  function register(Asset memory asset) external returns (uint256) {
    partsList[nextPartIndex] = asset;
    nextPartIndex++;
    return nextPartIndex - 1;
  }

  function generateSVGBody(uint256 id) internal view returns (bytes memory output) {
    Asset memory asset = partsList[id];
    uint256 size = asset.paths.length;
    SVG.Element[] memory elements = new SVG.Element[](size);
    for (uint i = 0; i < size; i++) {
      SVG.Element memory tmp = SVG.path(Path.decode(asset.paths[i]));
      if (keccak256(abi.encodePacked(asset.fills[i])) != keccak256(abi.encodePacked(''))) {
        tmp = tmp.fill(asset.fills[i]);
      }
      if (asset.strokes[i] != 0) {
        tmp = tmp.stroke('#000', asset.strokes[i]); // color, width
        tmp = tmp.style('stroke-linecap:round;stroke-linejoin:round;');
      }
      elements[i] = tmp;
    }
    output = SVG.list(elements).svg();
  }

  function getSVGBody(uint256 index) external view override returns (bytes memory output) {
    output = generateSVGBody(index);
  }

  function getSVG(uint256 index) external view override returns (string memory output) {
    SVG.Element[] memory samples = new SVG.Element[](0);

    output = SVG.document('0 0 1024 1024', SVG.list(samples).svg(), generateSVGBody(index));
  }
}

// SPDX-License-Identifier: MIT

/*
 * Logo Art
 *
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import '../../packages/graphics/Path.sol';
import '../../packages/graphics/SVG.sol';

import '../interfaces/IParts.sol';
import '../interfaces/ISVGArt.sol';

contract LogoArt1 is ISVGArt {
  using Strings for uint256;
  using Strings for uint16;
  using Path for uint[];
  using SVG for SVG.Element;

  IParts[] partsList;

  constructor(IParts[] memory _partsList) {
    for (uint i = 0; i < _partsList.length; i++) {
      partsList.push(_partsList[i]);
    }
  }

  function getParts(uint16 key, uint8 index) internal view returns (bytes memory output) {
    (uint16 sizes, bytes[] memory path, string[] memory fill, uint8[] memory stroke) = partsList[key].svgData(index);

    SVG.Element[] memory samples = new SVG.Element[](sizes);
    for (uint i = 0; i < sizes; i++) {
      SVG.Element memory tmp = SVG.path(Path.decode(path[i]));
      if (
        keccak256(abi.encodePacked(fill[i])) != keccak256(abi.encodePacked('')) &&
        keccak256(abi.encodePacked(fill[i])) != keccak256(abi.encodePacked('none'))
      ) {
        // tmp = tmp.fill(getColor(fill[i], swapKeys));
        tmp = tmp.fill(fill[i]);
      }
      if (stroke[i] != 0) {
        tmp = tmp.stroke('#000', stroke[i]); // color, width
        tmp = tmp.style('stroke-linecap:round;stroke-linejoin:round;');
      }
      samples[i] = tmp;
    }

    output = SVG.list(samples).svg();
  }

  function Omochikaeri() external view returns (bytes memory output) {
    return getParts(0, 0);
  }

  function SingularitySociety() external view returns (bytes memory output) {
    return getParts(1, 0);
  }

  function SingularitySocietyMark() external view returns (bytes memory output) {
    return getParts(2, 0);
  }

  function generateSVGBody(uint16 index) internal view returns (bytes memory output) {
    SVG.Element[] memory samples = new SVG.Element[](1);

    string memory tag = string(abi.encodePacked('Logo1', index.toString()));
    samples[0] = SVG.group(getParts(uint8(index % 3), 0)).id(tag);
    output = SVG.list(samples).svg();
  }

  function getSVGBody(uint16 index) external view override returns (bytes memory output) {
    output = generateSVGBody(index);
  }

  function getSVG(uint16 index) external view override returns (string memory output) {
    SVG.Element[] memory samples = new SVG.Element[](0);

    output = SVG.document('0 0 1024 1024', SVG.list(samples).svg(), generateSVGBody(index));
  }
}

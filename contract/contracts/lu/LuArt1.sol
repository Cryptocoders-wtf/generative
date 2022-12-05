// SPDX-License-Identifier: MIT

/*
 * Lu test
 * 
 *
 * Created by Isamu Arimoto (@isamu)
 */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../packages/graphics/Path.sol";
import "../packages/graphics/SVG.sol";
import "hardhat/console.sol";

import "./data/IParts.sol";
import "./ISVGArt.sol";

contract LuArt1 is ISVGArt {
  using Strings for uint256;
  using Path for uint[];
  using SVG for SVG.Element;

  IParts[] partsList;
  
  constructor(IParts[] memory _partsList) {
      for(uint i = 0; i < _partsList.length; i++) {
          partsList.push(_partsList[i]);
      }
  }

  function getTransformData(uint16 key) internal pure returns(uint16[3] memory) { 
      uint16[3][18] memory transformData = [
                                            [1000,0,0],
                                            [962, 39, 70],
                                            [130, 199, 793],
                                            [212, 465, 560],
                                            [220, 467, 552],
                                            [434, 338, 96],
                                            [283, 415, 105],
                                            [410,  355, 134],
                                            [98, 507, 269],
                                            [426, 345, 354],
                                            [416, 204, 498],
                                            [423, 187, 496],
                                            [236, 345, 353],
                                            [238, 348, 354],
                                            [174, 484, 198],
                                            [54, 635, 555],
                                            [125, 615, 545],
                                            [203, 600, 500]
                                            ];
      return transformData[key];
  }
          
  function getParts(uint16 key) internal view returns(bytes memory output) {
      (uint16 sizes, bytes[] memory path, string[] memory fill,  uint8[] memory stroke) = partsList[key].svgData();
      
      SVG.Element[] memory samples = new SVG.Element[](sizes);
      for(uint i = 0; i < sizes; i++) {
          SVG.Element memory tmp = SVG.path(Path.decode(path[i]));
          if (keccak256(abi.encodePacked(fill[i])) != keccak256(abi.encodePacked("")) &&
              keccak256(abi.encodePacked(fill[i])) != keccak256(abi.encodePacked("none"))) {
              // tmp = tmp.fill(getColor(fill[i], swapKeys));
              tmp = tmp.fill(fill[i]);
          }
          if (stroke[i] != 0) {
              tmp = tmp.stroke("#000", stroke[i]); // color, width
              tmp = tmp.style("stroke-linecap:round;stroke-linejoin:round;");
          }
          samples[i] = tmp;
      }
      
      output = SVG.list(samples).svg();
  }

  function getResizedParts(uint16 index) internal view returns(SVG.Element memory output) {
      uint16[3] memory tdata = getTransformData(index);
      return SVG.group(
                       SVG.group(
                                 SVG.group(getParts(index))
                                 .transform(string(abi.encodePacked("scale(", uint(tdata[0]).toString(), ")")))
                                 ).transform("scale(0.001)")
                       ).transform(string(abi.encodePacked("translate(", uint(tdata[1]).toString(), ", ", uint(tdata[2]).toString(), ")")));
  }
  
  function BgBlue() internal view returns(bytes memory output) {
      return getParts(0);
  }
  function BgRainbow() internal view returns(bytes memory output) {
      return getParts(1);      
  }
  function Chair() internal view returns(bytes memory output) {
      return getParts(2);      
  }
  function Door2() internal view returns(bytes memory output) {
      return getParts(3);      
  }
  function Door7() internal view returns(bytes memory output) {
      return getParts(4);      
  }
  function Heart1() internal view returns(bytes memory output) {
    return getParts(5);      
  }
  function Heart2() internal view returns(bytes memory output) {
      return getParts(6);      
  }
  function Heart3() internal view returns(bytes memory output) {
      return getParts(7);      
  }
  function HeartSP() internal view returns(bytes memory output) {
      return getParts(8);      
  }
  function House() internal view returns(bytes memory output) {
      return getParts(9);      
  }
  function Lu1() internal view returns(bytes memory output) {
      return getParts(10);      
  }
  function Lu2() internal view returns(bytes memory output) {
      return getParts(11);      
  }
  function Roof01() internal view returns(bytes memory output) {
      return getParts(12);      
  }
  function Roof05() internal view returns(bytes memory output) {
      return getParts(13);      
  }
  function TextSweet() internal view returns(bytes memory output) {
      return getParts(14);      
  }
  // 0, 1, 2
  function windows(uint16 index) internal view returns(SVG.Element memory output) {
      return getResizedParts((index % 3) + 15);
  }
  // 0, 1
  function door(uint16 index) internal view returns(SVG.Element memory output) {
      return getResizedParts((index % 2) + 3);
  }
  // 0, 1
  function roof(uint16 index) internal view returns(SVG.Element memory output) {
      return getResizedParts((index % 2) + 12);
  }
  // 0, 1, 2, 3
  function heart(uint16 index) internal view returns(SVG.Element memory output) {
      return getResizedParts((index % 4) + 5);
  }
  // 0, 1
  function lu(uint16 index) internal view returns(SVG.Element memory output) {
      return getResizedParts((index % 2) + 10);
  }
  
  function getSVG(uint16 index) external view override returns(string memory output) {
     SVG.Element[] memory samples = new SVG.Element[](10);

     samples[0] = SVG.group(BgBlue());
     //  rainbow
     samples[1] = getResizedParts(1);
     // chair
     samples[2] = getResizedParts(2);
     // house
     samples[3] = getResizedParts(9);
     // door 2 or 7
     samples[4] = door(index % 2);
     // roof 1, 5
     samples[5] = roof((index / 2) % 2);
     //  heart  1, 2, 3, sp
     samples[6] = heart((index / 4) % 4);
     // text sweeet
     samples[7] = getResizedParts(14);
     // window 1, 2, 3
     samples[8] = windows((index / 16) % 3);
     // lu 1, 2
     samples[9] = lu((index / 48) %2);

     SVG.Element[] memory samples2 = new SVG.Element[](0);
     
     output = SVG.document(
                           "0 0 1024 1024",
                           SVG.list(samples2).svg(),
                           SVG.list(samples).svg()
                           );
  }
}

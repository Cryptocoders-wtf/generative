// SPDX-License-Identifier: MIT

/*
 * Lu Art
 *
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import '../../packages/graphics/Path.sol';
import '../../packages/graphics/SVG.sol';

import '../interfaces/IParts.sol';
import '../interfaces/ISVGArt.sol';

contract LuArt1 is ISVGArt {
  using Strings for uint256;
  using Path for uint[];
  using SVG for SVG.Element;

  IParts[] partsList;

  constructor(IParts[] memory _partsList) {
    for (uint i = 0; i < _partsList.length; i++) {
      partsList.push(_partsList[i]);
    }
  }

  function getTransformData(uint16 key) internal pure returns (uint16[3] memory) {
    uint16[3][21] memory transformData = [
                                          [1000, 0, 0], // BG
                                          [130, 167, 817], // Chair
                                          [973, 28, 44], // CloudRainbow
                                          [941, 46, 33], // cloud
                                          [257, 432, 533], // DoorsetA
                                          [257, 434, 533], // DoorsetB
                                          [257, 432, 533], // DoorsetC
                                          [492, 288, 65], // HeartA
                                          [748, 144, 97], // HeartB
                                          [508, 278, 72],  // HeartC 
                                          [935, 34, 25], // Heartcloud
                                          [426, 314, 378], // HouseBase
                                          [412, 180, 526], // Lu01
                                          [326, 183, 616], // Lu02body2
                                          [161, 146, 519], // Lu02head1
                                          [155, 150, 527], // Lu02head2
                                          [73, 265, 762], //  Plane
                                          [917, 0, 0], // RainbowA
                                          [238, 316, 378], // RoofA
                                          [228, 313, 377], // RoofB
                                          [228, 313, 377] // RoofC
                                          ]; 
    return transformData[key];
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

  function getResizedParts(uint16 key, uint8 index) internal view returns (SVG.Element memory output) {
    uint16[3] memory tdata = getTransformData(key);
    return
      SVG
        .group(
          SVG
            .group(
              SVG.group(getParts(key, index)).transform(
                string(abi.encodePacked('scale(', uint(tdata[0]).toString(), ')'))
              )
            )
            .transform('scale(0.001)')
        )
        .transform(
          string(abi.encodePacked('translate(', uint(tdata[1]).toString(), ', ', uint(tdata[2]).toString(), ')'))
        );
  }

  function Bg() external view returns(bytes memory output) {
    return getParts(0, 2);
  }
  function Chair() external view returns(bytes memory output) {
    return getParts(1, 0);
  }
  function CloudRainbow() external view returns(bytes memory output) {
    return getParts(2, 0);
  }
  function Clouds() external view returns(bytes memory output) {
    return getParts(3, 0);
  }
  function DoorsetA() external view returns(bytes memory output) {
    return getParts(4, 0);
  }
  function DoorsetB() external view returns(bytes memory output) {
    return getParts(5, 0);
  }
  function DoorsetC() external view returns(bytes memory output) {
    return getParts(6, 0);
  }
  function HeartA() external view returns(bytes memory output) {
    return getParts(7, 0);
  }
  function HeartB() external view returns(bytes memory output) {
    return getParts(8, 0);
  }
  function HeartC() external view returns(bytes memory output) {
    return getParts(9, 0);
  }
  function Heartcloud() external view returns(bytes memory output) {
    return getParts(10, 0);
  }
  function HouseBase() external view returns(bytes memory output) {
    return getParts(11, 0);
  }
  function Lu01() external view returns(bytes memory output) {
    return getParts(12, 0);
  }
  function Lu02body2() external view returns(bytes memory output) {
    return getParts(13, 0);
  }
  function Lu02head1() external view returns(bytes memory output) {
    return getParts(14, 0);
  }
  function Lu02head2() external view returns(bytes memory output) {
    return getParts(15, 0);
  }
  function Plane() external view returns(bytes memory output) {
    return getParts(16, 0);
  }
  function RainbowA() external view returns(bytes memory output) {
    return getParts(17, 0);
  }
  function RoofA() external view returns(bytes memory output) {
    return getParts(18, 0);
  }
  function RoofB() external view returns(bytes memory output) {
    return getParts(19, 0);
  }
  function RoofC() external view returns(bytes memory output) {
    return getParts(20, 0);
  }

  function getBG(uint16 index) internal view returns (SVG.Element memory output) {
      if (index < 2) {
          // 0, 1
          // Clouds()
          return SVG.group([
                            SVG.group(getResizedParts(0, uint8(index))),
                            SVG.group(getResizedParts(3, 0))
                            ]);
      } else if (index < 8) {
          // 2, 3,4,5,6,7
          // CloudRainbow
          return SVG.group([
                            SVG.group(getResizedParts(0, uint8(index - 2))),
                            SVG.group(getResizedParts(2, 0))
                            ]);
      } else if (index < 11) {
          // 8,9,10
          // Heartcloud
          return SVG.group([
                            SVG.group(getResizedParts(0, uint8(index - 6))),
                            SVG.group(getResizedParts(10, 0))
                            ]);
      } 
      // RainbowA
      return SVG.group([
                        SVG.group(getResizedParts(0, 5)),
                        SVG.group(getResizedParts(17, 0))
                        ]);
  }

  function getHome(uint16 index) internal view returns (SVG.Element memory output) {
      if (index < 4) {
          return SVG.group([
                     SVG.group(getResizedParts(4 + index % 2, 0)),
                     SVG.group(getResizedParts(18 + (index / 2) % 2, 0))
                     ]);
      }
      return SVG.group([
                        SVG.group(getResizedParts(6, 0)),
                        SVG.group(getResizedParts(20, 0))
                        ]);
      
  }
  function getHeart(uint16 index) internal view returns (SVG.Element memory output) {
      // 7,8,9
      return SVG.group(getResizedParts((index / 2) % 3 + 7, 0));
  }
  function getLu(uint16 index) internal view returns (SVG.Element memory output) {
      if ((index % 2) == 0) {
        // Lu01             
              return SVG.group(getResizedParts(12, 0));
      }
      if ((index / 3) == 0) {
          // Lu02body2 + heade2 + plane
          return SVG.group([
                            SVG.group(getResizedParts(13, 0)),
                            SVG.group(getResizedParts(15, 0)),
                            SVG.group(getResizedParts(16, 0))
                            ]);
      } else {
          return SVG.group([
                            SVG.group(getResizedParts(13, 0)),
                            SVG.group(getResizedParts(14, 0))
                            ]);
      }
  }

  function generateSVGBody(uint16 index) internal view returns (bytes memory output) {
    SVG.Element[] memory samples = new SVG.Element[](6);

    // BgBlue
    samples[0] = getBG(uint8(index % 12));
    // HouseBase
    samples[1] =  SVG.group(getResizedParts(11, 0));
    
    samples[2] = getHome((index /12) % 5);

    samples[3] =  SVG.group(getResizedParts(1, 0));

    // Heart
    samples[4] = SVG.group(getHeart((index / 60) % 6 ));

    // Lu
    samples[5] = SVG.group(getLu((index / 60) % 6 ));

    output = SVG.list(samples).svg();
  }

  function getSVGBody(uint16 index) external view override returns (bytes memory output) {
    output = generateSVGBody(index);
  }
  function getSVG(uint16 index) external view override returns (string memory output) {
    SVG.Element[] memory samples = new SVG.Element[](0);

    output = SVG.document('0 0 1024 1024', SVG.list(samples).svg(), generateSVGBody(index));
  }
  function traits(string memory _type, string memory _value) private pure returns (bytes memory trait) {
      trait = abi.encodePacked('{"trait_type": "',  _type, '", "value": "', _value, '"}');
  }
  function bgTraits(uint256 index) private pure returns (bytes memory trait) {
      string memory tmp = "";

      string[] memory bgColors = new string[](6);
      bgColors[0] = "#66c5c8";
      bgColors[1] = "#a3df87";
      bgColors[2] = "#ffc764";
      bgColors[3] = "#f57596";
      bgColors[4] = "#df92d3";
      bgColors[5] = "#7d869a";

      string memory color = "";
      if (index < 2) {
          tmp = "Clouds";
          color = bgColors[index];
      } else if (index < 8) {
          tmp = "CloudRainbow";
          color	= bgColors[index - 2];
      } else if (index < 11) {
          tmp = "Heartcloud";
          color = bgColors[index - 6];
      } else {
          tmp = "Rainbow";
          color = bgColors[5];
      }
      trait = abi.encodePacked(traits("BackGround", tmp), ",", traits("BackGroundColor", color) );
  }

   // 0 - 4
   function homeTraits(uint256 index) private pure returns (bytes memory trait) {
       string memory door = "";
       string memory roof = "";
       if (index < 4) {
           door = (index % 2) == 0 ? "DoorsetA" : "DoorsetB";  // 0 or 1
           roof = ((index / 2) % 2) == 0 ? "RoofA" : "RoofB"; // 0or 1
       } else {
           door = "DoorsetC";
           roof = "RoofC";
       }
       trait = abi.encodePacked(traits("Door", door), ",", traits("Roof", roof) );
  }
  function heartTraits(uint256 index) private pure returns (bytes memory trait) {
      uint256 i = (index / 2) % 3;
      string memory v = "";
      if (i == 0) {
          v = "HeartA";
      }
      if (i == 1) {
          v = "HeartB";
      }
      if (i == 2) {
          v = "HeartC";
      }
      trait = abi.encodePacked(traits("Heart", v));
  }
  function luTraits(uint256 index) private pure returns (bytes memory trait) {
      string memory v = "";
      if ((index % 2) == 0) {
          v = "Lu1";
      } else if ((index / 3) == 0) {
          v = "Lu2";
      } else {
          v = "Lu3";
      }
      trait = abi.encodePacked(traits("Lu", v));
  }

          
   function generateTraits(uint256 _assetId) external view returns (string memory traits) {
       traits = string(abi.encodePacked('[',
                                        bgTraits(_assetId % 12), ",",
                                        homeTraits((_assetId/12) % 5), ",",
                                        heartTraits((_assetId / 60) % 6), ",",
                                        luTraits((_assetId/ 60) % 6),
                                        ']'));

  }
}

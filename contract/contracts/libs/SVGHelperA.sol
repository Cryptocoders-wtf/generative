// SPDX-License-Identifier: MIT

/*
 * Helper methods for SVG generative.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/ISVGHelper.sol";

contract SVGHelperA is ISVGHelper {
  using Strings for uint32;

  /**
   * Generate a SVG path from series of control points
   *
   * Note: It is possible to significantly improve this using assembly (see SVGPathDecoderA). 
   */
  function PathFromPoints(Point[] memory points) external override pure returns(bytes memory) {
    bytes memory ret;
    assembly{
      function foo() -> cmd, bar {
        cmd := 0x434445
        bar := 3
      }
      ret := mload(0x40)
      let retMemory := add(ret, 0x20)

      let cmd 
      let lenCmd
      cmd, lenCmd := foo()
      mstore(retMemory, shl(sub(256, mul(lenCmd, 8)), cmd))
      retMemory := add(retMemory, lenCmd)

      mstore(ret, sub(sub(retMemory, ret), 0x20))
      mstore(0x40, retMemory)
    }
    return ret;
/*
    uint length = points.length;
    for(uint256 i = 0; i < length; i++) {
      Point memory point = points[i];
      Point memory prev = points[(i + length - 1) % length];
      int32 sx = (point.x + prev.x) / 2;
      int32 sy = (point.y + prev.y) / 2;
      if (i == 0) {
        path = abi.encodePacked("M", uint32(sx).toString(), ",", uint32(sy).toString());
      }

      Point memory next = points[(i + 1) % length];
      int32 ex = (point.x + next.x) / 2;
      int32 ey = (point.y + next.y) / 2;
      if (point.c) {
        path = abi.encodePacked(path, "L", uint32(point.x).toString(), ",", uint32(point.y).toString(),
          ",", uint32(ex).toString(), ",", uint32(ey).toString());
      } else {
        path = abi.encodePacked(path, "C",
          uint32(sx + point.r * (point.x - sx) / 1024).toString(), ",",
          uint32(sy + point.r * (point.y - sy) / 1024).toString(), ",",
          uint32(ex + point.r * (point.x - ex) / 1024).toString(), ",",
          uint32(ey + point.r * (point.y - ey) / 1024).toString(), ",",
          uint32(ex).toString(), ",", uint32(ey).toString());
      }
    }
*/
  }  
}
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
  function PathFromPoints(Point[] memory points) external override pure returns(bytes memory path) {
    uint256 length = points.length;
    assembly {
      path := mload(0x40)
      let wbuf := add(path, 0x20)
      let rbuf := add(points, 0x20)
      for { let i:=0 } lt(i, length) { i := add(i,1)} {
        /*
        let point := mload(rbuf)
        let x := and(point, 0xffffffff)
        point := shr(32, point)
        let y := and(point, 0xffffffff)
        */
        let cmd := 0x3132
        cmd := shl(254, cmd)
        mstore(wbuf, cmd)
        wbuf := add(wbuf, 2)
      }
      mstore(path, sub(sub(wbuf, path), 0x20))
      mstore(0x40, wbuf)
    }
    /*
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
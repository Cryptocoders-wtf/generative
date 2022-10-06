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
  function PathFromPoints(uint[] memory points) external override pure returns(bytes memory path) {
    uint length = points.length;
    assembly{
      function toString(_wbuf, _value) -> wbuf {
        let len := 2
        let cmd := 0
        if gt(_value,9) {
          if gt(_value,99) {
            if gt(_value,999) {
              cmd := or(shl(8, cmd), add(48, div(_value, 1000))) 
              len := add(1, len)
              _value := mod(_value, 1000)
            }
            cmd := or(shl(8, cmd), add(48, div(_value, 100)))
            len := add(1, len)
            _value := mod(_value, 100)
          }
          cmd := or(shl(8, cmd), add(48, div(_value, 10)))
          len := add(1, len)
          _value := mod(_value, 10)
        }
        cmd := or(or(shl(16, cmd), shl(8, add(48, _value))), 32)

        mstore(_wbuf, shl(sub(256, mul(len, 8)), cmd))
        wbuf := add(_wbuf, len)
      }

      // dynamic allocation
      path := mload(0x40)
      let wbuf := add(path, 0x20)
      let rbuf := add(points, 0x20)

      let wordP := mload(add(rbuf, mul(sub(length,1), 0x20)))
      let word := mload(rbuf)
      for {let i := 0} lt(i, length) {i := add(i, 1)} {
        let x := and(word, 0xffff)
        let y := and(shr(word, 16), 0xffff)
        let r := and(shr(word, 32), 0xffff)
        {
          let sx := div(add(x, and(wordP, 0xffff)),2)
          let sy := div(add(y, and(shr(wordP, 16), 0xffff)),2)
          if eq(i, 0) {
            mstore(wbuf, shl(248, 0x4D)) // M
            wbuf := add(wbuf, 1)
            wbuf := toString(wbuf, sx)
            wbuf := toString(wbuf, sy)
          }
        }
        
        let wordN := mload(add(rbuf, mul(mod(add(i,1), length), 0x20)))
        {
          let ex := div(add(x, and(wordN, 0xffff)),2)
          let ey := div(add(y, and(shr(wordN, 16), 0xffff)),2)

          switch mload(and(shr(word,48),0x01)) 
            case 0 {
              mstore(wbuf, shl(248, 0x43)) // C
              wbuf := add(wbuf, 1)
              wbuf := toString(wbuf, x)
              wbuf := toString(wbuf, y)
              wbuf := toString(wbuf, x)
              wbuf := toString(wbuf, y)
            }
            default {
              mstore(wbuf, shl(248, 0x4C)) // L
              wbuf := add(wbuf, 1)
            }
          wbuf := toString(wbuf, ex)
          wbuf := toString(wbuf, ey)
        }
        wordP := word
        word := wordN
      }

      mstore(path, sub(sub(wbuf, path), 0x20))
      mstore(0x40, wbuf)
    }
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

  /**
   * Benchmarking
   */
  function generateSVGPart(IAssetProvider provider, uint256 _assetId) external view override returns(string memory svgPart, string memory tag, uint256 gas) {
    gas = gasleft();
    (svgPart, tag) = provider.generateSVGPart(_assetId);
    gas -= gasleft();
  }
}
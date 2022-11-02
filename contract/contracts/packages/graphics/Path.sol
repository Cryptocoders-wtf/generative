// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import "./Vector.sol";

library Path {
  function roundedCorner(Vector.Struct memory _vector) internal pure returns(uint) {
    return uint(_vector.x/0x8000) + (uint(_vector.y/0x8000) << 32) + (566 << 64);
  }

  function sharpCorner(Vector.Struct memory _vector) internal pure returns(uint) {
    return uint(_vector.x/0x8000) + (uint(_vector.y/0x8000) << 32) + (0x1 << 80);
  }

  function closedPath(uint[] memory points) internal pure returns(bytes memory newPath) {
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
      newPath := mload(0x40)
      let wbuf := add(newPath, 0x20)
      let rbuf := add(points, 0x20)

      let wordP := mload(add(rbuf, mul(sub(length,1), 0x20)))
      let word := mload(rbuf)
      for {let i := 0} lt(i, length) {i := add(i, 1)} {
        let x := and(word, 0xffffffff)
        let y := and(shr(32, word), 0xffffffff)
        let r := and(shr(64, word), 0xffff)
        let sx := div(add(x, and(wordP, 0xffffffff)),2)
        let sy := div(add(y, and(shr(32, wordP), 0xffffffff)),2)
        if eq(i, 0) {
          mstore(wbuf, shl(248, 0x4D)) // M
          wbuf := add(wbuf, 1)
          wbuf := toString(wbuf, sx)
          wbuf := toString(wbuf, sy)
        }
        
        let wordN := mload(add(rbuf, mul(mod(add(i,1), length), 0x20)))
        {
          let ex := div(add(x, and(wordN, 0xffffffff)),2)
          let ey := div(add(y, and(shr(32, wordN), 0xffffffff)),2)

          switch and(shr(80, word), 0x01) 
            case 0 {
              mstore(wbuf, shl(248, 0x43)) // C
              wbuf := add(wbuf, 1)
              x := mul(x, r)
              y := mul(y, r)
              r := sub(1024, r)
              wbuf := toString(wbuf, div(add(x, mul(sx, r)),1024))
              wbuf := toString(wbuf, div(add(y, mul(sy, r)),1024))
              wbuf := toString(wbuf, div(add(x, mul(ex, r)),1024))
              wbuf := toString(wbuf, div(add(y, mul(ey, r)),1024))
            }
            default {
              mstore(wbuf, shl(248, 0x4C)) // L
              wbuf := add(wbuf, 1)
              wbuf := toString(wbuf, x)
              wbuf := toString(wbuf, y)
            }
          wbuf := toString(wbuf, ex)
          wbuf := toString(wbuf, ey)
        }
        wordP := word
        word := wordN
      }

      mstore(newPath, sub(sub(wbuf, newPath), 0x20))
      mstore(0x40, wbuf)
    }
  }
}
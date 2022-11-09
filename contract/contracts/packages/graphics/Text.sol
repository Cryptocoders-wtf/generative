// SPDX-License-Identifier: MIT

/*
 * This is a part of fully-on-chain.sol, a npm package that allows developers
 * to create fully on-chain generative art.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

library Text {
  function extractLine(string memory _text) internal pure returns(string memory line) {
    uint length = bytes(_text).length;
    assembly {
      line := mload(0x40)
      let wbuf := add(line, 0x20)
      let rbuf := add(_text, 0x20)
       // add(add(_text, 0x20), _index)
      let word := 0
      let shift := 0
      let i
      for {i := 0} lt(i, length) {i := add(i, 1)} {
        if eq(mod(i, 0x20), 0) {
          word := mload(rbuf)
          mstore(wbuf, word)
          rbuf := add(rbuf, 0x20)
          wbuf := add(wbuf, 0x20)
          shift := 248
        }
        let char := and(shr(shift, word), 0xff)
        if eq(char, 0x0a) {
          length := i
        }
        shift := sub(shift, 8)
      }

      // index := i
      mstore(line, length) //sub(i, _index))
      mstore(0x40, add(add(line, 0x20), length))
    }
  }
}
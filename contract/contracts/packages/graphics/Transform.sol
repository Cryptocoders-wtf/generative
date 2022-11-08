// SPDX-License-Identifier: MIT

/*
 * This is a part of fully-on-chain.sol, a npm package that allows developers
 * to create fully on-chain generative art.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/Strings.sol";

library TX {
  using Strings for uint;

  function translate(uint x, uint y) internal pure returns(string memory) {
    return string(abi.encodePacked('translate(',x.toString(),' ',y.toString(),')'));
  }

  function scale(string memory _base, string memory _scale) internal pure returns(string memory) {
    return string(abi.encodePacked(_base, ' scale(', _scale ,')'));
  }
}
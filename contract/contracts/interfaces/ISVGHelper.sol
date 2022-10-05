// SPDX-License-Identifier: MIT

/*
 * Interface to helper contract(s) for SVG generative.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

interface ISVGHelper {
  // point
  // 0-15: int x
  // 16-31: int y
  // 32-47: uint r
  // 48: bool c
  function PathFromPoints(uint[] memory points) external pure returns(bytes memory);
}
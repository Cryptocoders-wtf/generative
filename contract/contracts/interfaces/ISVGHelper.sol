// SPDX-License-Identifier: MIT

/*
 * Interface to helper contract(s) for SVG generative.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

interface ISVGHelper {
  struct Point {
    int32 x;
    int32 y;
    int32 r; // ratio (0 to 1024)
    bool c; // true:line, false:bezier
  }
  function PathFromPoints(Point[] memory points) external pure returns(bytes memory);
}
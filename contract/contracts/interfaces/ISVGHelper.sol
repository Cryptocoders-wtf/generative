// SPDX-License-Identifier: MIT

/*
 * Interface to helper contract(s) for SVG generative.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { IAssetProvider } from './IAssetProvider.sol';

interface ISVGHelper {
  struct Point {
    int32 x;
    int32 y;
    bool c;   // true:line, false:bezier
    int32 r; // ratio (0 to 1024)
  }
  function PathFromPoints(Point[] memory points) external pure returns(bytes memory);
  function generateSVGPart(IAssetProvider provider, uint256 _assetId) external view returns(string memory svgPart, string memory tag, uint256 gas);
}
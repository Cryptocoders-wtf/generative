// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface ISVGStoreV1 {
  struct Asset {
    bytes[] paths;
    string[] fills;
    uint8[] strokes;
  }
          
  function register(Asset memory asset) external returns (uint256);

  function getSVGBody(uint256 index) external view returns (bytes memory output);

  function getSVG(uint256 index) external view returns (string memory output);
}

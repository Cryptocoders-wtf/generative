// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IParts {
  function svgData(
    uint8 index
  ) external pure returns (uint16 sizes, bytes[] memory paths, string[] memory fill, uint8[] memory stroke);
}

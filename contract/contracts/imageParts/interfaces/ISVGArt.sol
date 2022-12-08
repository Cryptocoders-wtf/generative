// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface ISVGArt {
  function getSVGBody(uint16 index) external view returns (bytes memory output);

  function getSVG(uint16 index) external view returns (string memory output);
}

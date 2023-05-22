// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IMessageStoreV2 {
  struct Asset {
    string message;
    string color;
    string fontName;
    string assetName;
  }
  struct Box {
    uint256 w;
    uint256 h;
  }

  function register(Asset memory asset) external returns (uint256);

  function getAsset(uint256 index) external view returns (Asset memory);

  function getSVGBody(uint256 index) external view returns (bytes memory output);

  function getSVGBodyFromAsset(
    string memory message,
    string memory color,
    string memory fontName,
    Box memory box
  ) external view returns (bytes memory output);

  function getSVG(uint256 index) external view returns (string memory output);

  function getSVGMessage(
    string memory message,
    string memory color,
    string memory fontName,
    Box memory box
  ) external view returns (string memory output);

  function getMessage(uint256 index) external view returns (string memory output);

  function getNextPartIndex() external view returns (uint256);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IMessageToken {
  function getMessage(uint256 index) external view returns (string memory output);
  function getLatestMessage() external view returns (string memory output);
}

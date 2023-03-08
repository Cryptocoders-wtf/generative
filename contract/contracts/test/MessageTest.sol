// SPDX-License-Identifier: MIT

/*
 * Text package test
 *
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import '../packages/graphics/Text.sol';
import 'hardhat/console.sol';

contract TextSplitTest {
  using Strings for uint256;

  function splitOnNewline(string memory message) external pure returns (string[] memory output) {
    output = Text.split(message, 0x0a);
  }

  function extractLineOnNewline(string memory message, uint index) external pure returns (string memory output, uint i) {
    (output, i) = Text.extractLine(message, index, 0x0a);
  }
}

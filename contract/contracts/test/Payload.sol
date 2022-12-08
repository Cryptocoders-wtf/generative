// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';

contract Payload is Ownable {
  function destroy() external onlyOwner {
    selfdestruct(payable(owner()));      
  }
}
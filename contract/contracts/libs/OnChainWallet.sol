// SPDX-License-Identifier: MIT

/*
 * Super simple on-line wallet
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';

contract OnChainWallet is Ownable {
  function withdrawAll() external onlyOwner {
    address payable payableTo = payable(owner());
    payableTo.transfer(address(this).balance);
  }

  function transferAll(address payable _payableTo) external onlyOwner {
    _payableTo.transfer(address(this).balance);
  }

  function transfer(address payable _payableTo, uint amount) external onlyOwner {
    _payableTo.transfer(amount);
  }
}
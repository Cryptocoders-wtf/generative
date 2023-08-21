// SPDX-License-Identifier: GPL-3.0

/// @title Interface for NounsSeeder

/*********************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *********************************/

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/ILocalNounsToken.sol';

contract LocalNounsMinter is Ownable {
  ILocalNounsToken public token;

  constructor(ILocalNounsToken _token) {
    token = _token;
  }

  function setLocalNounsToken(ILocalNounsToken _token) external onlyOwner {
    token = _token;
  }

  function mintSelectedPrefecture(uint256 _prefectureId) public payable returns (uint256 tokenId) {
    return token.mintSelectedPrefecture(msg.sender, _prefectureId);
  }

  function mintSelectedPrefectureBatch(
    uint256[] memory _prefectureId,
    uint256[] memory _amount
  ) public payable returns (uint256 tokenId) {

    return token.mintSelectedPrefectureBatch(msg.sender, _prefectureId, _amount);
  }
}

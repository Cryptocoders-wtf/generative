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

  uint256 public mintPriceForSpecified = 0.03 ether;
  uint256 public mintPriceForNotSpecified = 0.01 ether;

  uint256 public constant mintMax = 1200;

  mapping(address => uint256) public preferentialPurchacedCount;

  enum SalePhase {
    Locked,
    PreSale,
    PublicSale
  }

  SalePhase public phase = SalePhase.Locked; // セールフェーズ

  address public administratorsAddress; // 運営ウォレット

  constructor(ILocalNounsToken _token) {
    token = _token;
    administratorsAddress = msg.sender;
  }

  function setLocalNounsToken(ILocalNounsToken _token) external onlyOwner {
    token = _token;
  }

  function setMintPriceForSpecified(uint256 _price) external onlyOwner {
    mintPriceForSpecified = _price;
  }

  function setMintPriceForNotSpecified(uint256 _price) external onlyOwner {
    mintPriceForNotSpecified = _price;
  }

  function setPhase(SalePhase _phase) external onlyOwner {
    phase = _phase;
  }

  function setAdministratorsAddress(address _admin) external onlyOwner {
    administratorsAddress = _admin;
  }

  function mintSelectedPrefecture(uint256 _prefectureId, uint256 _amount) public payable returns (uint256 tokenId) {
    require(phase != SalePhase.Locked, 'Sale is locked');
    return token.mintSelectedPrefecture(msg.sender, _prefectureId, _amount);
  }

  function withdraw() external payable onlyOwner {
    require(administratorsAddress != address(0), "administratorsAddress shouldn't be 0");
    (bool sent, ) = payable(administratorsAddress).call{ value: address(this).balance }('');
    require(sent, 'failed to move fund to administratorsAddress contract');
  }
}

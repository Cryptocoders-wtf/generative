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
import '../interfaces/ITokenGate.sol';

contract LocalNounsMinter is Ownable {
  // Fires when the purchase executed
  event MintSelectedPrefecture(uint256 prefectureId, uint256 amount, address minter);

  ILocalNounsToken public token;
  ITokenGate public immutable tokenGate;

  uint256 public mintPriceForSpecified = 0.03 ether;
  uint256 public mintPriceForNotSpecified = 0.01 ether;

  uint256 public mintMax = 1500;

  mapping(address => uint256) public preferentialPurchacedCount;

  enum SalePhase {
    Locked,
    PreSale,
    PublicSale
  }

  SalePhase public phase = SalePhase.Locked; // セールフェーズ

  address public administratorsAddress; // 運営ウォレット

  constructor(ILocalNounsToken _token, ITokenGate _tokenGate) {
    token = _token;
    administratorsAddress = msg.sender;
    tokenGate = _tokenGate;
  }

  function setMintMax(uint256 _mintMax) external onlyOwner {
    mintMax = _mintMax;
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
    if (phase == SalePhase.Locked) {
      revert('Sale is locked');
    } else if (phase == SalePhase.PreSale) {
      require(tokenGate.balanceOf(msg.sender) > 0, 'TokenGate token is needed');
    }

    require(token.totalSupply2() + _amount <= mintMax, 'Over the mint limit');

    uint256 mintPrice;
    if (_prefectureId == 0) {
      mintPrice = mintPriceForNotSpecified;
    } else {
      mintPrice = mintPriceForSpecified;
    }
    require(msg.value >= mintPrice * _amount, 'Must send the mint price');

    tokenId = token.mintSelectedPrefecture(msg.sender, _prefectureId, _amount);

    emit MintSelectedPrefecture(_prefectureId, _amount, msg.sender);
  }

  function withdraw() external payable onlyOwner {
    require(administratorsAddress != address(0), "administratorsAddress shouldn't be 0");
    (bool sent, ) = payable(administratorsAddress).call{ value: address(this).balance }('');
    require(sent, 'failed to move fund to administratorsAddress contract');
  }
}

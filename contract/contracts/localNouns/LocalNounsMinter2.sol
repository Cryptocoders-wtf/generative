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

contract LocalNounsMinter2 is Ownable {
  // Fires when the purchase executed
  event MintSelectedPrefecture(uint256 prefectureId, uint256 amount, address minter);

  ILocalNounsToken public token;
  ITokenGate public immutable tokenGate;
  
  address[] public royaltyAddresses; // ロイヤリティ送信先ウォレット
  mapping(address => uint256) public royaltyRatio; // ロイヤリティ送信先ウォレットごとの割合
  uint256 royaltyRatioTotal; // royaltyRatioの合計(割戻用)

  uint256 public mintPriceForSpecified = 0.03 ether;
  uint256 public mintPriceForNotSpecified = 0.01 ether;

  uint256 public mintMax = 1500;

  enum SalePhase {
    Locked,
    PreSale,
    PublicSale
  }

  SalePhase public phase = SalePhase.PublicSale; // セールフェーズ

  address public administratorsAddress; // 運営ウォレット

  constructor(ILocalNounsToken _token, ITokenGate _tokenGate) {
    token = _token;
    administratorsAddress = msg.sender;
    tokenGate = _tokenGate;

    // ロイヤリティ送信先(コンストラクタではデプロイアドレス100%)
    royaltyAddresses = [msg.sender];
    royaltyRatio[msg.sender] = 1;
    royaltyRatioTotal = 1;
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
    return mintSelectedPrefecture2(_prefectureId, _amount, msg.sender);
  }

  function mintSelectedPrefecture2(
    uint256 _prefectureId,
    uint256 _amount,
    address _mintTo
  ) public payable returns (uint256 tokenId) {
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

    tokenId = token.mintSelectedPrefecture(_mintTo, _prefectureId, _amount);

    _sendRoyalty(msg.value);

    emit MintSelectedPrefecture(_prefectureId, _amount, _mintTo);
  }

  function withdraw() external payable onlyOwner {
    _sendRoyalty(address(this).balance);
  }

  // send royalties to admin and developper
  function _sendRoyalty(uint _royalty) internal {
    for (uint256 i = 0; i < royaltyAddresses.length; i++) {
      _trySendRoyalty(royaltyAddresses[i], (_royalty * royaltyRatio[royaltyAddresses[i]]) / royaltyRatioTotal);
    }
  }

  function _trySendRoyalty(address to, uint amount) internal {
    (bool sent, ) = payable(to).call{ value: amount }('');
    require(sent, 'Failed to send');
  }

  function setRoyaltyAddresses(address[] memory _addr, uint256[] memory ratio) external onlyOwner {
    // 引数の整合性チェック
    require(_addr.length == ratio.length, 'Invalid Arrays length');
    royaltyAddresses = _addr;
    royaltyRatioTotal = 0;

    for (uint256 i = 0; i < _addr.length; i++) {
      royaltyRatio[_addr[i]] = ratio[i];
      royaltyRatioTotal += ratio[i];
    }
  }

}

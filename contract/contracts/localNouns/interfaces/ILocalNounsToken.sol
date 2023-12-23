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

interface ILocalNounsToken {
  function mintSelectedPrefecture(address to, uint256 prefectureId, uint256 _amount) external returns (uint256 tokenId);

  function setMinter(address _minter) external;

  // iLocalNounsTokenでERC721のtotalSupplyを使用したいけど、二重継承でエラーになるので個別関数を準備
  function totalSupply2() external returns (uint256);

  // Fires when the owner puts the trade
  event PutTradePrefecture(uint256 indexed tokenId, uint256[] _prefectures, address _tradeAddress);

  // Fires when the owner cancel the trade
  event CancelTradePrefecture(uint256 indexed tokenId);

  // Fires when the purchase executed
  event Purchase(uint256 indexed tokenId, address _buyer);

  // Fires when the trade executed
  event ExecuteTrade(uint256 indexed targetTokenId, address _lister, uint256 indexed ownedTokenId, address _executer);

}

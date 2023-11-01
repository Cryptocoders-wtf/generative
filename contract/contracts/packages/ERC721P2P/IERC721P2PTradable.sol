// SPDX-License-Identifier: MIT

/**
 * This is a part of an effort to update ERC271 so that the sales transaction
 * becomes decentralized and trustless, which makes it possible to enforce
 * royalities without relying on marketplaces.
 *
 * Please see "https://hackmd.io/@snakajima/BJqG3fkSo" for details.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import './IERC721P2P.sol';

interface IERC721P2PTradableCore {
  // Put the specified token to trade list(onlyTokenOwner)
  function putTrade(uint256 _tokenId, bool _isOnTrade) external;

  // Trade the specified tokens (onlyTokenOwner)
  function executeTrade(uint256 _myTokenId, uint256 _targetTokenId) external;

  // Fires when the owner puts the trade
  event PutTrade(uint256 indexed tokenId, bool _isOnTrade);
}

// deprecated
interface IERC721P2PTradable is IERC721P2PTradableCore, IERC721P2P {

}

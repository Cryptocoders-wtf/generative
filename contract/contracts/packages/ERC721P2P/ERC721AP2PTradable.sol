// SPDX-License-Identifier: MIT

/**
 * Inherits ERC721 as an extension
 * Please see "https://hackmd.io/@snakajima/BJqG3fkSo" for details.
 */

pragma solidity ^0.8.6;

import './IERC721P2PTradable.sol';
import './ERC721AP2P.sol';

abstract contract ERC721AP2PTradable is IERC721P2PTradableCore, ERC721AP2P {
  // onTradeList (tokenId => trade on/off)
  mapping(uint256 => bool) public trades;

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IERC721P2PTradableCore).interfaceId || super.supportsInterface(interfaceId);
  }

  function putTrade(uint256 _tokenId, bool _isOnTrade) external override {
    require(ownerOf(_tokenId) == msg.sender, 'Only the onwer can trade');
    trades[_tokenId] = _isOnTrade;
    emit PutTrade(_tokenId, _isOnTrade);
  }

  function executeTrade(uint256 _myTokenId, uint256 _targetTokenId) external override {
    require(ownerOf(_myTokenId) == msg.sender, 'Only the onwer can trade');
    require(trades[_targetTokenId] == true, 'TargetTokenId is not on trade');

    address targetTokenOwner = ownerOf(_targetTokenId);

    _transfer(msg.sender, targetTokenOwner, _myTokenId);
    _transfer(targetTokenOwner, msg.sender, _targetTokenId);
  }

  // transfer時はセール、トレード解除
  function _beforeTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity) internal override {
    trades[startTokenId] = false; // not trade any more
    prices[startTokenId] = 0; // not on sale any more
    super._beforeTokenTransfers(from, to, startTokenId, quantity);
  }
}

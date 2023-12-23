// SPDX-License-Identifier: MIT

/**
 * Inherits ERC721 as an extension
 * Please see "https://hackmd.io/@snakajima/BJqG3fkSo" for details.
 */

pragma solidity ^0.8.6;

import './IERC721P2P.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import './erc721a/extensions/ERC721AQueryable.sol';

abstract contract ERC721AP2P is IERC721P2PCore, ERC721A, Ownable {
  mapping(uint256 => uint256) prices;

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IERC721P2PCore).interfaceId || super.supportsInterface(interfaceId);
  }

  function setPriceOf(uint256 _tokenId, uint256 _price) public override {
    require(ownerOf(_tokenId) == msg.sender, 'Only the onwer can set the price');
    prices[_tokenId] = _price;
    emit SetPrice(_tokenId, _price);
  }

  function getPriceOf(uint256 _tokenId) external view override returns (uint256) {
    return prices[_tokenId];
  }

  function purchase(uint256 _tokenId, address _buyer, address _facilitator) external payable virtual {
    _purchase(_tokenId, _buyer, _facilitator);
  }

  function _purchase(uint256 _tokenId, address _buyer, address _facilitator) internal {
    uint256 price = prices[_tokenId];
    require(price > 0, 'Token is not on sale');
    require(msg.value >= price, 'Not enough fund');
    uint256 comission = _processSalesCommission(msg.value, _facilitator);
    uint256 royalty = _processRoyalty(msg.value, _tokenId);
    address tokenOwner = ownerOf(_tokenId);
    address payable payableTo = payable(tokenOwner);
    payableTo.transfer(msg.value - comission - royalty);
    prices[_tokenId] = 0; // not on sale any more

    _transfer(tokenOwner, _buyer, _tokenId);
    // transferFrom(tokenOwner, _buyer, _tokenId);
  }

  // 2.5% to the facilitator (marketplace)
  function _processSalesCommission(
    uint _salesPrice,
    address _facilitator
  ) internal virtual returns (uint256 comission) {
    if (_facilitator != address(0)) {
      comission = (_salesPrice * 25) / 1000; // 2.5%
      address payable payableTo = payable(_facilitator);
      payableTo.transfer(comission);
    }
  }

  // Subclass needs to override to pay royalties to creator(s) here
  function _processRoyalty(uint _salesPrice, uint _tokenId) internal virtual returns (uint256 royalty) {
    /*
    royalty = _salesPrice * 50 / 1000; // 5.0%
    address payable payableTo = payable(address(_creator));
    payableTo.transfer(royalty);
    */
  }

  function acceptOffer(uint256 _tokenId, IERC721Marketplace _dealer, uint256 _price) external override {
    setPriceOf(_tokenId, _price);
    _dealer.acceptOffer(this, _tokenId, _price);
  }
}

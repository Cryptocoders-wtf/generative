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

import "../interfaces/IERC721P2P.sol";
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract ERC721P2P is IERC721P2P, ERC721, Ownable {
  mapping (uint256 => uint256) prices;

  function setPriceOf(uint256 _tokenId, uint256 _price) external override {
    prices[_tokenId] = _price;
  }

  function getPriceOf(uint256 _tokenId) external view override returns(uint256) {
    return prices[_tokenId];
  }

  function purchase(uint256 _tokenId, address _wallet, address _facilitator) external payable override {

  }
  function acceptOffer(uint256 _tokenId, IERC721Marketplace _dealer, uint256 _price) external override {

  }
}
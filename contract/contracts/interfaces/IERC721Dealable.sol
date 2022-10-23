// SPDX-License-Identifier: MIT

/**
 * This is a part of an effort to create a decentralized autonomous marketplace for digital assets,
 * which allows artists and developers to sell their arts and generative arts.
 *
 * Please see "https://fullyonchain.xyz/" for details. 
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721Dealer {
  // Make an offer to a specific token
  function makeAnOffer(IERC721Dealable _contract, uint256 _tokenId, uint256 _price) external payable;
  // Withdraw an offer to a specific token (onlyOfferMaker)
  function withdrawAnOffer(IERC721Dealable _contract, uint256 _tokenId) external;
  // Get the current offer to the specifiedToken
  function getTheBestOffer(IERC721Dealable _contract, uint256 _tokenId) external view 
      returns(uint256, address);
  // It will call the purchase method of _contract with the specified amount of payment.
  function acceptOffer(IERC721Dealable _contract, uint256 _tokenId, uint256 _price) external;
}

interface IERC721Dealable is IERC721 {
  // Set the price of the specified token (onlyTokenOwner)
  function setPriceOf(uint256 _tokenId, uint256 _price) external;
  // Get the current price of the specified token
  function getPriceOf(uint256 _tokenId) external view returns(uint256);
  // It will transfer the token and distribute the money, including royalties
  function purchase(uint256 _tokenId, address _wallet) external payable;
  // It sets the price and calls the acceptOffer method of _dealer (onlyTokenOwner)
  function acceptOffer(uint256 _tokenId, IERC721Dealer _dealer, uint256 _price) external;
}
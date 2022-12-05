// SPDX-License-Identifier: MIT

/**
 * Inherits ERC721 as an extension
 * Please see "https://hackmd.io/@snakajima/BJqG3fkSo" for details. 
 */

pragma solidity ^0.8.6;

import "erc721a/contracts/IERC721A.sol";

interface IERC721AMarketplace {
  // Make an offer to a specific token
  function makeAnOffer(IERC721AP2P _contract, uint256 _tokenId, uint256 _price) external payable;
  // Withdraw an offer to a specific token (onlyOfferMaker)
  function withdrawAnOffer(IERC721AP2P _contract, uint256 _tokenId) external;
  // Get the current offer to the specifiedToken
  function getTheBestOffer(IERC721AP2P _contract, uint256 _tokenId) external view 
      returns(uint256, address);
  // It will call the purchase method of _contract with the specified amount of payment.
  function acceptOffer(IERC721AP2P _contract, uint256 _tokenId, uint256 _price) external;
}

interface IERC721AP2P is IERC721A {
  // Set the price of the specified token (onlyTokenOwner)
  function setPriceOf(uint256 _tokenId, uint256 _price) external;
  // Get the current price of the specified token
  function getPriceOf(uint256 _tokenId) external view returns(uint256);
  // It will transfer the token and distribute the money, including royalties
  function purchase(uint256 _tokenId, address _buyer, address _facilitator) external payable;
  // It sets the price and calls the acceptOffer method of _dealer (onlyTokenOwner)
  function acceptOffer(uint256 _tokenId, IERC721AMarketplace _dealer, uint256 _price) external;
}
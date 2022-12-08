// SPDX-License-Identifier: MIT

/*
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import './libs/ProviderToken.sol';

contract RedditToken is ProviderToken {
  using Strings for uint256;

  constructor(
    IAssetProvider _assetProvider,
    IProxyRegistry _proxyRegistry
  ) ProviderToken(_assetProvider, _proxyRegistry, 'On-Chain Reddit Art', 'Reddit') {
    description = 'This is a part of Fully On-chain Generative Art project (https://fullyonchain.xyz/). All images are dymically generated on the blockchain.';
    mintPrice = 0; // free
    mintLimit = 250; // initial limit, updatable with a hard limit of 1,000
  }

  function tokenName(uint256 _tokenId) internal pure override returns (string memory) {
    return string(abi.encodePacked('Reddit ', _tokenId.toString()));
  }

  function mint() public payable virtual override returns (uint256 tokenId) {
    require(balanceOf(msg.sender) == 0, 'You already have this token.');
    require(nextTokenId < 1000, 'Sold out'); // hard limit, regardless of updatable "mintLimit"
    tokenId = super.mint();
  }
}

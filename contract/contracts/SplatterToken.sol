// SPDX-License-Identifier: MIT

/*
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/Strings.sol";
import './libs/ProviderToken.sol';

contract SplatterToken is ProviderToken {
  using Strings for uint256;

  constructor(
    IAssetProvider _assetProvider,
    IProxyRegistry _proxyRegistry
  ) ProviderToken(_assetProvider, _proxyRegistry, "Splatter", "SPLATTER") {
    description = "This is a part of Fully On-chain Generative Art project (https://fullyonchain.xyz/).";
  }

  function tokenName(uint256 _tokenId) internal pure override returns(string memory) {
    return string(abi.encodePacked('Splatter ', _tokenId.toString()));
  }  
}

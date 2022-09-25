// SPDX-License-Identifier: MIT

/*
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/Strings.sol";
import './libs/ProviderTokenEx.sol';

contract SplatterToken is ProviderTokenEx {
  using Strings for uint256;

  constructor(
    IAssetProvider _assetProvider,
    address _developer,
    IProxyRegistry _proxyRegistry
  ) ProviderTokenEx(_assetProvider, _developer, _proxyRegistry, 4, "Splatter", "SPLATTER") {
    description = "This is a part of Fully On-chain Generative Art project (https://fullyonchain.xyz/).";
  }

  function tokenName(uint256 _tokenId) internal pure override returns(string memory) {
    return string(abi.encodePacked('Splatter ', _tokenId.toString()));
  }  
}

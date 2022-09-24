// SPDX-License-Identifier: MIT

/*
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "erc721a/contracts/ERC721A.sol";
import { Base64 } from 'base64-sol/base64.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import { IProxyRegistry } from './external/opensea/IProxyRegistry.sol';
import { IAssetProvider } from './interfaces/IAssetProvider.sol';
import './libs/ProviderToken.sol';

contract SplatterToken is ProviderToken {
  using Strings for uint256;

  constructor(
    IAssetProvider _assetProvider,
    address _developer,
    IProxyRegistry _proxyRegistry
  ) ProviderToken(_assetProvider, _developer, _proxyRegistry, 4, "Splatter", "SPLATTER") {
    description = "This is a part of Fully On-chain Generative Art project (https://fullyonchain.xyz/).";
  }

  function tokenName(uint256 _tokenId) internal pure override returns(string memory) {
    return string(abi.encodePacked('Splatter ', _tokenId.toString()));
  }  
}

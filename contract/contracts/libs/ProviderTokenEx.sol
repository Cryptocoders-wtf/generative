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

import "./ProviderToken.sol";

abstract contract ProviderTokenEx is ProviderToken {
  using Strings for uint256;
  
  uint256 nextTokenId;

  constructor(
    IAssetProvider _assetProvider,
    IProxyRegistry _proxyRegistry,
    string memory _title,
    string memory _shortTitle
  ) ProviderToken(_assetProvider, _proxyRegistry, _title, _shortTitle) {
  }

  /**
   * For non-free minting,
   * 1. Override this method
   * 2. Check for the required payment
   * 3. Call the processPayout method of the asset provider with appropriate value
   */
  function mint() external virtual payable {
    uint256 tokenId = nextTokenId++; 
    _safeMint(msg.sender, tokenId);
  }

  function generateTraits(uint256 _tokenId) internal pure override returns (bytes memory) {
    return abi.encodePacked(
      '{'
        '"trait_type":"Seed",'
        '"value":"', _tokenId.toString(), '"' 
      '}'
    );
  }

  function debugTokenURI(uint256 _tokenId) public view returns (string memory uri, uint256 gas) {
    gas = gasleft();
    uri = tokenURI(_tokenId);
    gas -= gasleft();
  }
}
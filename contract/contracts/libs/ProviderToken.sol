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
import { IProxyRegistry } from '../external/opensea/IProxyRegistry.sol';
import { IAssetProvider } from '../interfaces/IAssetProvider.sol';

abstract contract ProviderToken is Ownable, ERC721A {
  using Strings for uint256;
  using Strings for uint16;

  string public description;

  // developer address.
  address public developer;

  // OpenSea's Proxy Registry
  IProxyRegistry public immutable proxyRegistry;

  IAssetProvider public immutable assetProvider;

  constructor(
    IAssetProvider _assetProvider,
    address _developer,
    IProxyRegistry _proxyRegistry,
    string memory _title,
    string memory _shortTitle
  ) ERC721A(_title, _shortTitle)  {
    assetProvider = _assetProvider;
    developer = _developer;
    proxyRegistry = _proxyRegistry;
  }

  /*
   * @notice get next tokenId.
   */
  function getCurrentToken() external view returns (uint256) {                  
    return _nextTokenId();
  }

  /**
    * @notice Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
    */
  function isApprovedForAll(address owner, address operator) public view override returns (bool) {
      // Whitelist OpenSea proxy contract for easy trading.
      if (proxyRegistry.proxies(owner) == operator) {
          return true;
      }
      return super.isApprovedForAll(owner, operator);
  }

  string constant SVGHeader = '<svg viewBox="0 0 1024 1024'
      '"  xmlns="http://www.w3.org/2000/svg">\n'
      '<defs>\n';

  /*
   * A function of IAssetStoreToken interface.
   * It generates SVG with the specified style, using the given "SVG Part".
   */
  function generateSVG(uint256 _assetId) internal view returns (string memory) {
    // Constants of non-value type not yet implemented by Solidity
    (string memory svgPart, string memory tag) = assetProvider.generateSVGPart(_assetId);
    return string(abi.encodePacked(
      SVGHeader, 
      svgPart,
      '</defs>\n'
      ' <use href="', tag, '" />\n'
      '</svg>\n'));
  }

  function generateTraits(uint256 _tokenId) internal view virtual returns (bytes memory) {
    return abi.encodePacked(
      '{'
        '"trait_type":"TokenId",'
        '"value":"', _tokenId.toString(), '"' 
      '}'
    );
  }

  function setDescription(string memory _description) external onlyOwner {
      description = _description;
  }

  /**
    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    * @dev See {IERC721Metadata-tokenURI}.
    */
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_exists(_tokenId), 'KamonToken.tokenURI: nonexistent token');
    bytes memory image = bytes(generateSVG(_tokenId));

    return string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(
          bytes(
            abi.encodePacked(
              '{"name":"', tokenName(_tokenId), 
                '","description":"', description, 
                '","attributes":[', generateTraits(_tokenId), 
                '],"image":"data:image/svg+xml;base64,', 
                Base64.encode(image), 
              '"}')
          )
        )
      )
    );
  }

  function tokenName(uint256 _tokenId) internal view virtual returns(string memory) {
    return _tokenId.toString();
  }  
}
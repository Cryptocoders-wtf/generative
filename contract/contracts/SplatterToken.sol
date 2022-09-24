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

contract SplatterToken is Ownable, ERC721A {
  using Strings for uint256;
  using Strings for uint16;

  uint256 constant _tokensPerAsset = 4;

  // description
  string public description = "This is ...";

  // developer address.
  address public developer;

  // OpenSea's Proxy Registry
  IProxyRegistry public immutable proxyRegistry;

  IAssetProvider public immutable assetProvider;

  /**
   */
  constructor(
    IAssetProvider _assetProvider,
    address _developer,
    IProxyRegistry _proxyRegistry
  ) ERC721A("Kamon Symbols by Hakko Daiodo", "KAMON") {
    assetProvider = _assetProvider;
    developer = _developer;
    proxyRegistry = _proxyRegistry;
  }

  function _isPrimary(uint256 _tokenId) internal pure returns(bool) {
    return _tokenId % _tokensPerAsset == 0;
  }

  /**
   */
  function mint(uint256 _affiliate) external {
    uint256 tokenId = _nextTokenId(); 
    _mint(msg.sender, _tokensPerAsset - 1);

    // Specified affliate token must be one of the primary tokens and not owned by the minter.
    if (_affiliate > 0 && _isPrimary(_affiliate) && ownerOf(_affiliate) != msg.sender) {
      _mint(ownerOf(_affiliate), 1);
    } else if ((tokenId / _tokensPerAsset) % 2 == 0) {
      // 1 in 20 tokens of non-affiliated mints go to the developer
      _mint(developer, 1);
    } else {
      // the rest goes to the owner for distribution
      _mint(owner(), 1);
    }
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
    string memory svgPart;
    string memory tag;
    (svgPart, tag) = assetProvider.generateSVGPart(_assetId);
    bytes memory image = abi.encodePacked(SVGHeader, svgPart);
    image =  abi.encodePacked(
      image,
      '</defs>\n'
      ' <use href="', tag, '" />\n'
      '</svg>\n');
    return string(image);
  }

  function _generateTraits(uint256 _tokenId) internal pure returns (bytes memory) {
    return abi.encodePacked(
      '{'
        '"trait_type":"Primary",'
        '"value":"', _isPrimary(_tokenId) ? 'Yes':'No', '"' 
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
              '{"name":"', 'Splatter ', _tokenId.toString(), 
                '","description":"', description, 
                '","attributes":[', _generateTraits(_tokenId), 
                '],"image":"data:image/svg+xml;base64,', 
                Base64.encode(image), 
              '"}')
          )
        )
      )
    );
  }  

  function tokensPerAsset() public pure returns(uint256) {
    return _tokensPerAsset;
  }
}

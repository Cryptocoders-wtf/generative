// SPDX-License-Identifier: MIT

/*
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/Strings.sol";
import { Base64 } from 'base64-sol/base64.sol';
// import './libs/ProviderToken2.sol';
import "./interfaces/ITokenGate.sol";
import "./packages/ERC721P2P/ERC721P2P.sol";
import "assetprovider.sol/IAssetProvider.sol";

contract DotNounsToken is ERC721P2P {
  using Strings for uint256;

  uint public nextTokenId;
  ITokenGate public immutable tokenGate;
  IAssetProvider public immutable assetProvider;
  string public description; 
  uint public mintPrice; 

  constructor(
    ITokenGate _tokenGate,
    IAssetProvider _assetProvider
  ) ERC721("Dot Nouns", "DOTNOUNS") {
    assetProvider = _assetProvider;
    tokenGate = _tokenGate;
    description = "This is a part of Fully On-chain Generative Art project (https://fullyonchain.xyz/). All images are dymically generated on the blockchain.";
    mintPrice = 1e16; //0.01 ether, updatable
  }

  function tokenName(uint256 _tokenId) internal pure returns(string memory) {
    return string(abi.encodePacked('Dot Nouns ', _tokenId.toString()));
  }

  function mint() public virtual payable returns(uint256 tokenId) {
    require(nextTokenId < 2500, "Sold out"); // hard limit, regardless of updatable "mintLimit"
    require(msg.value >= mintPriceFor(msg.sender), 'Must send the mint price');
    require(balanceOf(msg.sender) < 3, "Too many tokens");
    tokenId = nextTokenId++; 
    _safeMint(msg.sender, tokenId);
    assetProvider.processPayout{value:msg.value}(tokenId); // 100% distribution to the asset provider
  }

  function totalSupply() public view returns (uint256) {
    return nextTokenId;
  }

  function mintPriceFor(address _wallet) public view virtual returns(uint256) {
    if (balanceOf(_wallet) == 1) {
      return mintPrice * 2; // x2 for second
    } else if (balanceOf(_wallet) == 2) {
      return mintPrice * 4; // x4 for third
    }
    if (tokenGate.balanceOf(_wallet) > 0) {
      return mintPrice / 2; // 50% off
    }
    return mintPrice;
  }

  function _processRoyalty(uint _salesPrice, uint _tokenId) internal override returns(uint256 royalty) {
    royalty = _salesPrice * 50 / 1000; // 5.0%
    assetProvider.processPayout{value:royalty}(_tokenId);
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
      '<use href="#', tag, '" />\n'
      '</svg>\n'));
  }

  function generateTraits(uint256 _tokenId) internal view returns (bytes memory traits) {
    traits = bytes(assetProvider.generateTraits(_tokenId));
  }

  /**
    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    * @dev See {IERC721Metadata-tokenURI}.
    */
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_exists(_tokenId), 'ProviderToken.tokenURI: nonexistent token');
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

}

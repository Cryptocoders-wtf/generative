// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import './packages/ERC721P2P/ERC721P2P.sol';
import { Base64 } from 'base64-sol/base64.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import './imageParts/interfaces/ISVGArt.sol';

contract LuTokenProto is ERC721P2P {
  using Strings for uint256;

  uint public nextTokenId;

  // To be specified by the concrete contract
  string public description;
  uint public mintPrice;
  uint internal _mintLimit; // with a virtual getter

  ISVGArt immutable svgArt;

  constructor(string memory _title, string memory _shortTitle, ISVGArt _svgArt) ERC721(_title, _shortTitle) {
    mintPrice = 1e16; //0.01 ether, updatable
    svgArt = _svgArt;
    _mintLimit = 100;
  }

  function tokenName(uint256 _tokenId) internal pure returns (string memory) {
    return string(abi.encodePacked('Laidback Lu ', _tokenId.toString()));
  }

  function _processRoyalty(uint _salesPrice, uint _tokenId) internal override returns (uint256 royalty) {
    royalty = (_salesPrice * 50) / 1000; // 5.0%
    // assetProvider.processPayout{value:royalty}(_tokenId);
  }

  function setDescription(string memory _description) external onlyOwner {
    description = _description;
  }

  function setMintPrice(uint256 _price) external onlyOwner {
    mintPrice = _price;
  }

  function setMintLimit(uint256 _limit) external onlyOwner {
    _mintLimit = _limit;
  }

  function mintLimit() public view virtual returns (uint256) {
    return _mintLimit;
  }

  /*
   * A function of IAssetStoreToken interface.
   * It generates SVG with the specified style, using the given "SVG Part".
   */
  function generateSVG(uint256 _assetId) internal view returns (string memory) {
    return svgArt.getSVG(uint16(_assetId % 96));
  }

  /**
   * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
   * @dev See {IERC721Metadata-tokenURI}.
   */
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_exists(_tokenId), 'ProviderToken.tokenURI: nonexistent token');
    bytes memory image = bytes(generateSVG(_tokenId));

    return
      string(
        abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name":"',
                tokenName(_tokenId),
                '","description":"',
                description,
                '","attributes":[',
                generateTraits(_tokenId),
                '],"image":"data:image/svg+xml;base64,',
                Base64.encode(image),
                '"}'
              )
            )
          )
        )
      );
  }

  /**
   * For non-free minting,
   * 1. Override this method
   * 2. Check for the required payment, by calling mintPriceFor()
   * 3. Call the processPayout method of the asset provider with appropriate value
   */
  function mint() public payable virtual returns (uint256 tokenId) {
    require(nextTokenId < mintLimit(), 'Sold out');
    tokenId = nextTokenId++;
    _safeMint(msg.sender, tokenId);
  }

  /**
   * The concreate contract may override to offer custom pricing,
   * such as token-gated discount.
   */
  function mintPriceFor(address) public view virtual returns (uint256) {
    return mintPrice;
  }

  function totalSupply() public view returns (uint256) {
    return nextTokenId;
  }

  function generateTraits(uint256 _tokenId) internal view returns (bytes memory traits) {
    // traits = bytes(assetProvider.generateTraits(_tokenId));
  }

  function debugTokenURI(uint256 _tokenId) public view returns (string memory uri, uint256 gas) {
    gas = gasleft();
    uri = tokenURI(_tokenId);
    gas -= gasleft();
  }
}

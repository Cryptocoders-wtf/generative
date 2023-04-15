// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import './libs/ProviderToken4.sol';
import './imageParts/interfaces/ISVGStoreV1.sol';
import './providers/SVGImage1Provider.sol';

contract SVGTokenV1 is ProviderToken4 {
  using Strings for uint256;

  ISVGStoreV1 public immutable svgStoreV1;
  mapping(uint256 => uint256) assetIds; // tokenId => assetId
  mapping(uint256 => address) private minters;

  constructor(
    IAssetProvider _assetProvider,
    ISVGStoreV1 _svgStore
  ) ProviderToken4(_assetProvider, 'SVGTokenV1', 'SVGTokenV1') {
    description = 'SVGTokenV1';
    svgStoreV1 = _svgStore;
    setMintLimit(1e50);
  }

  function _processRoyalty(uint _salesPrice, uint _tokenId) internal override returns (uint256 royalty) {
    royalty = (_salesPrice * 50) / 1000; // 5.0%
    payable(minters[_tokenId]).transfer(royalty);
  }

  // Helper method for test script
  function etherBalanceOf(address _wallet) public view returns (uint256) {
    return _wallet.balance;
  }

  function tokenName(uint256 _tokenId) internal pure override returns (string memory) {
    return string(abi.encodePacked('SVG Token V1 ', _tokenId.toString()));
  }

  function mint() public payable override returns (uint256 tokenId) {
    require(false, 'must not call');
  }

  function mintWithAsset(ISVGStoreV1.Asset memory asset) public returns (uint256 tokenId) {
    uint256 assetId = svgStoreV1.register(asset);
    tokenId = super.mint();
    assetIds[tokenId] = assetId;
    minters[tokenId] = msg.sender;
  }

  function mintToSell(ISVGStoreV1.Asset memory asset, uint price) public returns (uint256 tokenId) {
    tokenId = mintWithAsset(asset);
    setPriceOf(tokenId, price);
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    uint256 assetId = assetIds[_tokenId];
    require(_exists(_tokenId), 'SVGToken.tokenURI: nonexistent token');
    bytes memory image = bytes(generateSVG(assetId));

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
                generateTraits(assetId),
                '],"image":"data:image/svg+xml;base64,',
                Base64.encode(image),
                '"}'
              )
            )
          )
        )
      );
  }
}

// SPDX-License-Identifier: MIT

/*
 * Created by Takuya Mizutani (@Takuya-Mizutani)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import './libs/ProviderTokenA1.sol';
import './imageParts/interfaces/IMessageStoreV2.sol';
// import './providers/MessageProvider.sol';

import './interfaces/IMessageToken.sol';

contract MessageTokenV2 is ProviderTokenA1, IMessageToken {
  using Strings for uint256;

  IMessageStoreV2 immutable messageStore;

  mapping(uint256 => uint256) assetIds; // tokenId => assetId

  constructor(
    IAssetProvider _assetProvider,
    IMessageStoreV2 _messageStore
  ) ProviderTokenA1(_assetProvider, 'MessageTokenV2', 'MessageTokenV2') {
    description = 'MessageTokenV2';
    messageStore = _messageStore;
    mintLimit = 1e50;
  }

  function tokenName(uint256 _tokenId) internal pure override returns (string memory) {
    return string(abi.encodePacked('MessageTokenV2 ', _tokenId.toString()));
  }

  function mint() public payable override returns (uint256 tokenId) {
    require(false, 'must not call');
  }

  function mintWithAsset(IMessageStoreV2.Asset memory asset) public returns (uint256 tokenId) {
    uint256 assetId = messageStore.register(asset);
    tokenId = super.mint();
    assetIds[tokenId] = assetId;
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    uint256 assetId = assetIds[_tokenId];
    require(_exists(_tokenId), 'MessageToken.tokenURI: nonexistent token');
    bytes memory image = bytes(generateSVG(assetId)); // ProviderTokenA1.generateSVG

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

  function getMessage(uint256 index) external view returns (string memory output) {
      output = messageStore.getMessage(assetIds[index]);
  }
  
  function getLatestMessage() external view returns (string memory output) {
      output = messageStore.getMessage(assetIds[_nextTokenId() - 1]); 
  }

  function getAsset(uint256 index) external view returns (IMessageStoreV2.Asset memory output) {
      output = messageStore.getAsset(assetIds[index]);
  }

  function getAssetId(uint256 index) external view returns (uint256 output) {
      output = assetIds[index];
  }
}

// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import './libs/ProviderTokenA1.sol';
import './imageParts/interfaces/IMessageStoreV1.sol';
import './providers/MessageProvider.sol';

contract MessageToken is ProviderTokenA1 {
  using Strings for uint256;

  IMessageStoreV1 immutable messageStore;
  mapping(uint256 => uint256) assetIds; // tokenId => assetId

  constructor(
    IAssetProvider _assetProvider,
    IMessageStoreV1 _messageStore
  ) ProviderTokenA1(_assetProvider, 'MessageToken', 'MessageToken') {
    description = 'MessageToken';
    messageStore = _messageStore;
    mintLimit = 1e50;
  }

  function tokenName(uint256 _tokenId) internal pure override returns (string memory) {
    return string(abi.encodePacked('Message Token V1 ', _tokenId.toString()));
  }

  function mint() public payable override returns (uint256 tokenId) {
    require(false, 'must not call');
  }

  function mintWithAsset(IMessageStoreV1.Asset memory asset) public returns (uint256 tokenId) {
    uint256 assetId = messageStore.register(asset);
    tokenId = super.mint();
    assetIds[tokenId] = assetId;
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    uint256 assetId = assetIds[_tokenId];
    require(_exists(_tokenId), 'MessageToken.tokenURI: nonexistent token');
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

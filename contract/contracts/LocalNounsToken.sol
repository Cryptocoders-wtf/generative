// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import './libs/ProviderTokenA1.sol';
import { INounsSeeder } from './localNouns/interfaces/INounsSeeder.sol';
import './localNouns/interfaces/IAssetProviderExMint.sol';
import './localNouns/interfaces/ILocalNounsToken.sol';

contract LocalNounsToken is ProviderTokenA1, ILocalNounsToken {
  using Strings for uint256;

  IAssetProviderExMint public assetProvider2;
  address public minter;

  constructor(IAssetProviderExMint _assetProvider, address _minter) ProviderTokenA1(_assetProvider, 'Local Nouns', 'Local Nouns') {
    description = 'Local Nouns Token.';
    assetProvider2 = _assetProvider;
    // mintPrice = 1e13; // 0.001
    mintPrice = 0; 
    mintLimit = 5000;
    minter = _minter;
  }

  function tokenName(uint256 _tokenId) internal pure override returns (string memory) {
    return string(abi.encodePacked('Local Nouns ', _tokenId.toString()));
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_tokenId < _nextTokenId(), 'LocalNounsToken.tokenURI: nonexistent token');

    (string memory svgPart, string memory tag) = assetProvider2.generateSVGPart(_tokenId);
    bytes memory image = bytes(svgPart);

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
                image,
                '"}'
              )
            )
          )
        )
      );
  }

  function mintSelectedPrefecture(uint256 prefectureId) public virtual returns (uint256 tokenId) {
    require(msg.sender == minter, 'Sender is not the minter');
    assetProvider2.mint(prefectureId, _nextTokenId());
    super.mint();

    return _nextTokenId() - 1;
  }

  function setMinter(address _minter) public onlyOwner {
    minter = _minter;
  }
}

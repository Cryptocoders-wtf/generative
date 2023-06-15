// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import './libs/ProviderTokenA1.sol';
import { INounsSeeder } from './localNouns/interfaces/INounsSeeder.sol';
import './localNouns/interfaces/IAssetProviderExMint.sol';

contract LocalNounsToken is ProviderTokenA1 {
  using Strings for uint256;

  // fes committee
  address public committee;
  address public designer;
  address public developper;

  IAssetProviderExMint public assetProvider2;

  constructor(
    IAssetProviderExMint _assetProvider,
    address _committee,
    address _designer,
    address _developper
  ) ProviderTokenA1(_assetProvider, 'Local Nouns', 'Local Nouns') {
    description = 'Local Nouns Token.';
    assetProvider2 = _assetProvider;
    mintPrice = 1e13; // 0.001 
    mintLimit = 5000;
    committee = _committee;
    designer = _designer;
    developper = _developper;
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
  function mint(uint256 prefectureId) public payable virtual returns (uint256 tokenId) {
      require(msg.value >= mintPrice, 'Must send the mint price');
      assetProvider2.mint(prefectureId, _nextTokenId());
      super.mint();
      address payable payableTo = payable(committee);
      payableTo.transfer(address(this).balance);
      
      // if ((_nextTokenId() % 10) == 8) {
      //     assetProvider2.mint(_nextTokenId());
      //     _safeMint(designer, 1);
      //     assetProvider2.mint(_nextTokenId());
      //     _safeMint(developper, 1);
      // }
      return _nextTokenId() - 1;
  }
}

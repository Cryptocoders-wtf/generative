// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import './libs/ProviderTokenA1.sol';
import { INounsSeeder } from './sushi/interfaces/INounsSeeder.sol';
import './sushi/interfaces/IAssetProviderExMint.sol';

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
  ) ProviderTokenA1(_assetProvider, 'Sushi Nouns', 'Sushi Nouns') {
    description = 'Sushi Nouns Token.';
    assetProvider2 = _assetProvider;
    mintPrice = 1e15; // 0.1 
    mintLimit = 5000;
    committee = _committee;
    designer = _designer;
    developper = _developper;
  }

  function tokenName(uint256 _tokenId) internal pure override returns (string memory) {
    return string(abi.encodePacked('Sushi Nouns ', _tokenId.toString()));
  }
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
      require(_tokenId < _nextTokenId(), 'SushiNounsToken.tokenURI: nonexistent token');

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
                Base64.encode(image),
                '"}'
              )
            )
          )
        )
      );
  }
  function mint() public payable virtual override returns (uint256 tokenId) {
      require(msg.value >= mintPrice, 'Must send the mint price');
      assetProvider2.mint(_nextTokenId());
      super.mint();
      address payable payableTo = payable(committee);
      payableTo.transfer(address(this).balance);
      
      if ((_nextTokenId() % 10) == 8) {
          assetProvider2.mint(_nextTokenId());
          _safeMint(designer, 1);
          assetProvider2.mint(_nextTokenId());
          _safeMint(developper, 1);
      }
      return _nextTokenId() - 1;
  }
}

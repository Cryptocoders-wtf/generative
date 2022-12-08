// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import './libs/ProviderTokenA1.sol';

contract LuToken is ProviderTokenA1 {
  using Strings for uint256;

  constructor(IAssetProvider _assetProvider) ProviderTokenA1(_assetProvider, 'Laidback Lu', 'Laidback Lu') {
    description = 'Laidback Lu.';
    mintPrice = 1e16;
    mintLimit = 5000;
  }

  function tokenName(uint256 _tokenId) internal pure override returns (string memory) {
    return string(abi.encodePacked('Laidback Lu ', _tokenId.toString()));
  }

  function mint() public payable virtual override returns (uint256 tokenId) {
    if ((nextTokenId % 96) == 0) {
      // super mint
      require(msg.sender == owner(), 'must call onwer');
      _safeMint(msg.sender, 10);
      nextTokenId = nextTokenId + 10;
      return nextTokenId;
    } else {
      if (msg.sender != owner()) {
        require(balanceOf(msg.sender) < ((nextTokenId / 96) + 1) * 4 + 1, 'Too many tokens');
      }
      require(msg.value >= mintPrice, 'Must send the mint price');
      _safeMint(msg.sender, 1);
      return nextTokenId++;
    }
  }
}

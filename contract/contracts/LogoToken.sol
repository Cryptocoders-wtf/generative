// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import './libs/ProviderTokenA1.sol';

contract LogoToken is ProviderTokenA1 {
  using Strings for uint256;

  constructor(IAssetProvider _assetProvider) ProviderTokenA1(_assetProvider, 'Singularity Society Logo', 'SS Logo') {
    description = 'Singularity Society Logo';
    // mintPrice = 1e16;
    mintPrice = 0;
    mintLimit = 5000;
  }

  function tokenName(uint256 _tokenId) internal pure override returns (string memory) {
    return string(abi.encodePacked('Singularity Society ', _tokenId.toString()));
  }

  function mint() public payable virtual override returns (uint256 tokenId) {
    tokenId = super.mint();
  }
}

// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/Strings.sol";
import './libs/ProviderTokenA1.sol';

contract LuToken is ProviderTokenA1 {
  using Strings for uint256;

  constructor(
    IAssetProvider _assetProvider
  ) ProviderTokenA1(_assetProvider, "Laidback Lu", "Laidback Lu") {
    description = "Laidback Lu.";
    mintPrice = 0;
    mintLimit = 250;
  }

  function tokenName(uint256 _tokenId) internal pure override returns(string memory) {
    return string(abi.encodePacked('Laidback Lu ', _tokenId.toString()));
  }

  function mint() public override virtual payable returns(uint256 tokenId) {
    tokenId = super.mint();
  }
}

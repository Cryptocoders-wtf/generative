// SPDX-License-Identifier: MIT

/*
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/Strings.sol";
import './libs/ProviderToken.sol';
import "./interfaces/ITokenGate.sol";

contract SplatterToken is ProviderToken {
  using Strings for uint256;
  ITokenGate immutable tokenGate;

  constructor(
    ITokenGate _tokenGate,
    IAssetProvider _assetProvider,
    IProxyRegistry _proxyRegistry
  ) ProviderToken(_assetProvider, _proxyRegistry, "Splatter", "SPLATTER") {
    tokenGate = _tokenGate;
    description = "This is a part of Fully On-chain Generative Art project (https://fullyonchain.xyz/).";
    mintPrice = 1e16; //0.01 ether 
  }

  function tokenName(uint256 _tokenId) internal pure override returns(string memory) {
    return string(abi.encodePacked('Splatter ', _tokenId.toString()));
  }

  function mint() public override virtual payable {
    require(msg.value >= mintPriceFor(msg.sender), 'Must send the mint price');
    super.mint();
  }

  function mintPriceFor(address _wallet) public override view   virtual returns(uint256) {
    if (tokenGate.balanceOf(_wallet) > 0) {
      return mintPrice / 2; // 50% off
    }
    return mintPrice;
  }
}

// SPDX-License-Identifier: MIT

/*
 * This is a pert of Fully On-chain Generative Art project.
 *
 * web: https://fullyonchain.xyz/
 * github: https://github.com/Cryptocoders-wtf/generative
 * discord: https://discord.gg/4JGURQujXK
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import './libs/ProviderToken4.sol';
import './interfaces/ITokenGate.sol';

contract PaperNounsToken is ProviderToken4 {
  using Strings for uint256;
  ITokenGate public immutable tokenGate;
  bool public locked = true;

  constructor(
    ITokenGate _tokenGate,
    IAssetProvider _assetProvider
  ) ProviderToken4(_assetProvider, 'Paper Nouns', 'PAPERNOUNS') {
    tokenGate = _tokenGate;
    description = 'This is a part of Fully On-chain Generative Art project (https://fullyonchain.xyz/). All images are dymically generated on the blockchain.';
    mintPrice = 1e16; //0.01 ether, updatable
  }

  function setLock(bool _locked) external onlyOwner {
    locked = _locked;
  }

  // Disable any approve and transfer during the initial minting
  function setApprovalForAll(
    address operator,
    bool approved
  ) public virtual override(ERC721WithOperatorFilter, IERC721) {
    require(!locked, "The contract is locked during the initial minting.");
    super.setApprovalForAll(operator, approved);
  }

  function approve(address operator, uint256 tokenId) public virtual override(ERC721WithOperatorFilter, IERC721) {
    require(!locked, "The contract is locked during the initial minting.");
    super.approve(operator, tokenId);
  }

  function _isApprovedOrOwner(address spender, uint256 tokenId) internal view override returns (bool) {
    require(!locked, "The contract is locked during the initial minting.");
    return super._isApprovedOrOwner(spender, tokenId);
  }

  function tokenName(uint256 _tokenId) internal pure override returns (string memory) {
    return string(abi.encodePacked('Dot Nouns ', _tokenId.toString()));
  }

  function mint() public payable virtual override returns (uint256 tokenId) {
    require(nextTokenId < 2500, 'Sold out'); // hard limit, regardless of updatable "mintLimit"
    require(msg.value >= mintPriceFor(msg.sender), 'Must send the mint price');
    require(balanceOf(msg.sender) < 3, 'Too many tokens');

    // Special case for Nouns 245
    if (nextTokenId == 245) {
      tokenId = nextTokenId++;
      _safeMint(owner(), tokenId);
    }
    tokenId = super.mint();

    assetProvider.processPayout{ value: msg.value }(tokenId); // 100% distribution to the asset provider
  }

  function mintLimit() public view override returns (uint256) {
    return assetProvider.totalSupply();
  }

  function mintPriceFor(address _wallet) public view virtual override returns (uint256) {
    if (balanceOf(_wallet) > 0) {
      return mintPrice * 4; // x4 for second
    }
    if (tokenGate.balanceOf(_wallet) > 0) {
      return mintPrice / 2; // 50% off
    }
    if (locked) {
      return mintPrice * 4; // x4 while locked for non-WL holders
    }
    return mintPrice;
  }

  function _processRoyalty(uint _salesPrice, uint _tokenId) internal override returns (uint256 royalty) {
    royalty = (_salesPrice * 50) / 1000; // 5.0%
    assetProvider.processPayout{ value: royalty }(_tokenId);
  }
}

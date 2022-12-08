// SPDX-License-Identifier: MIT

/**
 * This is a part of an effort to update ERC271 so that the sales transaction
 * becomes decentralized and trustless, which makes it possible to enforce
 * royalities without relying on marketplaces.
 *
 * Please see "https://hackmd.io/@snakajima/BJqG3fkSo" for details.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import './ERC721P2P.sol';

contract SampleP2PToken is ERC721P2P {
  uint public nextTokenId;
  uint constant mintLimit = 100;
  address payable immutable artist;

  constructor(address _artist) ERC721('sample', 'SAMPLE') {
    artist = payable(_artist);
  }

  function _processRoyalty(uint _salesPrice, uint) internal override returns (uint256 royalty) {
    royalty = (_salesPrice * 50) / 1000; // 5.0%
    artist.transfer(royalty);
  }

  function mint() public payable virtual returns (uint256 tokenId) {
    require(nextTokenId < mintLimit, 'Sold out');
    tokenId = nextTokenId++;
    _safeMint(msg.sender, tokenId);
  }

  function totalSupply() public view returns (uint256) {
    return nextTokenId;
  }

  // Helper method for test script
  function etherBalanceOf(address _wallet) public view returns (uint256) {
    return _wallet.balance;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import './ERC721AP2PTradable.sol';

contract SampleAP2PTradableToken is ERC721AP2PTradable {
  uint public nextTokenId;
  uint constant mintLimit = 100;
  address payable immutable artist;

  constructor(address _artist) ERC721A('sample', 'SAMPLE') {
    artist = payable(_artist);
  }

  function _processRoyalty(uint _salesPrice, uint) internal override returns (uint256 royalty) {
    royalty = (_salesPrice * 50) / 1000; // 5.0%
    artist.transfer(royalty);
  }

  function mint() public payable virtual returns (uint256 tokenId) {
    require(nextTokenId < mintLimit, 'Sold out');
    tokenId = nextTokenId++;
    _safeMint(msg.sender, 1);
  }


  // Helper method for test script
  function etherBalanceOf(address _wallet) public view returns (uint256) {
    return _wallet.balance;
  }
}

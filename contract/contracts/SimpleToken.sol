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

import './packages/ERC721P2P/ERC721AP2P.sol';
import './packages/ERC721P2P/erc721a/IERC721A.sol';

contract SimpleToken is ERC721AP2P {
  uint public nextTokenId;
  uint constant mintLimit = 100;
  IERC721A private immutable baseToken;
  uint256 private immutable baseAssetId;
  
  constructor(IERC721A _baseToken, uint256 assetId) ERC721A('sample', 'SAMPLE') {
      baseToken = _baseToken;
      baseAssetId = assetId;
  }

  function _processRoyalty(uint _salesPrice, uint) internal override returns (uint256 royalty) {
      royalty = (_salesPrice * 50) / 1000; // 5.0%
    // artist.transfer(royalty);
  }

  function mint() public payable virtual returns (uint256 tokenId) {
    require(nextTokenId < mintLimit, 'Sold out');
    tokenId = nextTokenId++;
    _safeMint(msg.sender, 1);
  }
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
      return baseToken.tokenURI(baseAssetId);
  }

  // Helper method for test script
  function etherBalanceOf(address _wallet) public view returns (uint256) {
    return _wallet.balance;
  }
}

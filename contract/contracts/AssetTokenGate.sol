// SPDX-License-Identifier: MIT

/*
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract AssetTokenGate is Ownable {
  IERC721[] whitelist;

  function setWhitelist(IERC721[] memory _whitelist) external onlyOwner {
    whitelist = _whitelist;
  }

  function totalBalanceOf(address _wallet) external view returns(uint balance) {
    for (uint i=0; i<whitelist.length; i++) {
      balance += whitelist[i].balanceOf(_wallet);
    }
  }
}

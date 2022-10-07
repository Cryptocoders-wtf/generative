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

  function hasWhitelistToken(address _wallet) external view returns(bool) {
    for (uint i=0; i<whitelist.length; i++) {
      if (whitelist[i].balanceOf(_wallet) > 0) {
        return true;
      }
    }
    return false;
  }
}

// SPDX-License-Identifier: MIT

/**
 * Inherits ERC721 as an extension
 * Please see "https://hackmd.io/@snakajima/BJqG3fkSo" for details. 
 */

pragma solidity ^0.8.6;

import "erc721a/contracts/IERC721A.sol";
import "./IERC721P2P.sol";

interface IERC721AP2P is IERC721A, IERC721P2PCore {
}
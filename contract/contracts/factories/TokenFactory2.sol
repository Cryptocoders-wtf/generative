// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import "../packages/ERC721P2P/IERC721P2P.sol";

import "../SimpleToken.sol";

contract TokenFactory2 {
    IERC721A private immutable baseToken;

    mapping(uint256 => ERC721AP2P) tokens; // tokenId => token
    
    constructor(IERC721A _token) {
        baseToken = _token;
    }
    function forkContract(uint256 assetId) public returns (ERC721AP2P _token){
        _token = new SimpleToken(baseToken, assetId);
        tokens[assetId] = _token;
    }

}

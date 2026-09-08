// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

// import "./packages/ERC721P2P/IERC721P2P.sol";
import "../SVGTokenV1.sol";
import "../ISVGTokenV1.sol";

// import "./packages/ERC721P2P/SampleAP2PToken.sol";

contract TokenFactory {
    ISVGTokenV1 public immutable token;
    constructor(ISVGTokenV1 _token) {
        token = _token;
    }
    function forkContract() public returns (
        IAssetProvider _assetProvider,
        ISVGStoreV1 _svgStore
    )  {
        ISVGTokenV1.ContractInfo memory info = token.getContractInfo(0);
        new SVGTokenV1(info.assetProvider, info.svgStore);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import './imageParts/interfaces/ISVGStoreV1.sol';
import './providers/SVGImage1Provider.sol';


interface ISVGTokenV1 {
    struct ContractInfo {
        IAssetProvider assetProvider;
        ISVGStoreV1 svgStore;
        uint256 assetId;
        address owner;
    }
    function getContractInfo(uint256 _tokenId) external returns (ContractInfo memory);
}

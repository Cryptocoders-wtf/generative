// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import 'assetprovider.sol/IAssetProvider.sol';

interface IAssetProviderExMint is IAssetProvider {
    function mint(uint256 prefectureId, uint256 _assetId) external returns (uint256);
    function getPrefectureId(uint256 prefectureId) external returns (uint256);
}

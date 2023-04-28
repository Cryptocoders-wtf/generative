// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import 'assetprovider.sol/IAssetProvider.sol';

interface IAssetProviderExMint is IAssetProvider {
    function mint(uint256 _assetId) external returns (uint256);
}

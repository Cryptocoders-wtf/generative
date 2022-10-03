// SPDX-License-Identifier: MIT

/**
 * This is a part of an effort to create a decentralized autonomous marketplace for digital assets,
 * which allows artists and developers to sell their arts and generative arts.
 *
 * Please see "https://fullyonchain.xyz/" for details. 
 *
 * Created by Satoshi Nakajima (@snakajima)
 */
pragma solidity ^0.8.6;

import { IAssetProvider } from '../interfaces/IAssetProvider.sol';
import { Randomizer } from '../libs/Randomizer.sol';

interface IAssetProviderEx is IAssetProvider {
  function generateRandomProps(Randomizer.Seed memory _seed) external pure returns(Randomizer.Seed memory, uint256);
  function generatePathWithProps(Randomizer.Seed memory _seed, uint256 _prop) external view returns(Randomizer.Seed memory seed, bytes memory svgPart);
}

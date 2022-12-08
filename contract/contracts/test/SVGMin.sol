// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import 'randomizer.sol/Randomizer.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import 'fully-on-chain.sol/Path.sol';
import 'fully-on-chain.sol/SVG.sol';
import 'hardhat/console.sol';

contract SVGMin {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Vector for Vector.Struct;
  using Path for uint[];
  using SVG for SVG.Element;

  function main() external pure returns (bytes memory output) {
    return SVG.rect(256, 256, 512, 512).svg();
  }
}

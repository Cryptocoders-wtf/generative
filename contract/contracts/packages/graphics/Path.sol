// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import "./Vector.sol";

library Path {
  function roundedCorner(Vector.Struct memory _vector) internal pure returns(uint) {
    return uint(_vector.x/0x8000) + (uint(_vector.y/0x8000) << 16) + (566 << 32);
  }

  function sharpCorner(Vector.Struct memory _vector) internal pure returns(uint) {
    return uint(_vector.x/0x8000) + (uint(_vector.y/0x8000) << 16) + (0x1 << 48);
  }
}
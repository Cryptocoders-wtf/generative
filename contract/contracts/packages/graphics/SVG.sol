// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import "bytes-array.sol/BytesArray.sol";

library SVG {
  using BytesArray for bytes[];

  function path(bytes memory _path, bytes memory _id) internal pure returns(bytes memory svg) {
    svg = abi.encodePacked(
      '<path id="', _id, '" d="', _path, '"/>\n'
    );
  }

  function group(bytes[] memory _parts, bytes memory _id) internal pure returns(bytes memory svg) {
    svg = abi.encodePacked(
      '<g id="', _id, '">', _parts.packed(), '</g>\n'
    );
  }
}
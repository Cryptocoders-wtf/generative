// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

library SVG {
  function path(bytes memory _path, bytes memory _tag) internal pure returns(bytes memory svg) {
    svg = abi.encodePacked(
      '<path id="', _tag, '" d="', _path, '"/>\n'
    );
  }
}
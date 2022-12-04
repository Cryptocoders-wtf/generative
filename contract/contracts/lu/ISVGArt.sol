// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface ISVGArt {
    function getSVG(uint16 index) external view returns(string memory output);
}


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IMessageStoreV1 {
    struct Asset {
        string message;
        string color;
    }
    function register (Asset memory asset) external returns (uint256);

    function getSVGBody(uint256 index) external view returns (bytes memory output);

    function getSVG(uint256 index) external view returns (string memory output);

    function getSVGMessage(string memory message, string memory color) external view returns (string memory output);

}

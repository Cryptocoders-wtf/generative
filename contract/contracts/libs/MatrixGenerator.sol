// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import "randomizer.sol/Randomizer.sol";

contract MatrixGenerator {
  using Randomizer for Randomizer.Seed;
  struct Node {
    uint x;
    uint y;
    string scale;
    bool skip;
  }

  function generate(Randomizer.Seed memory _seed)  
              external pure returns(Randomizer.Seed memory seed, Node[16][16] memory nodes) {
    seed = _seed;
    Node memory node;
    for (uint j = 0; j < 16; j++) {
      node.y = j * 64;
      for (uint i = 0; i < 16; i++) {
        if (nodes[i][j].skip) {
          continue;
        }
        node.x = i * 64;
        node.scale = '0.0625'; // 1/16
        uint index;  
        (seed, index) = seed.random(100);
        if (i % 2 ==0 && j % 2 == 0) {
          if (i % 8 ==0 && j % 8 == 0 && index<18) {
            node.scale = '0.5'; // 1/2
            for (uint k=0; k<64; k++) {
              nodes[i + k % 8][j + k / 8].skip = true;
            }
          } else if (i % 4 ==0 && j % 4 == 0 && index<50) {
            node.scale = '0.25'; // 1/4
            for (uint k=0; k<16; k++) {
              nodes[i + k % 4][j + k / 4].skip = true;
            }
          } else if (index<80) {
            node.scale = '0.125'; // 1/8
            nodes[i+1][j].skip = true;
            nodes[i][j+1].skip = true;
            nodes[i+1][j+1].skip = true;
          }
        }
        nodes[i][j] = node;
      }
    }
  }
}
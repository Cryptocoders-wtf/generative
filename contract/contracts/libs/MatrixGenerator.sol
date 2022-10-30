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
    uint size;
    string scale;
  }

  function generate(Randomizer.Seed memory _seed, uint _ratio2, uint _ratio4, uint _ratio8)
              external pure returns(Randomizer.Seed memory seed, Node[] memory nodes) {
    seed = _seed;
    Node memory node;
    Node[16][16] memory nodesFixed;
    bool[16][16] memory filled;
    uint count;

    for (uint j = 0; j < 16; j++) {
      node.y = j * 64;
      for (uint i = 0; i < 16; i++) {
        if (filled[i][j]) {
          continue;
        }
        node.x = i * 64;
        node.scale = '0.0625'; // 1/16
        node.size = 64;
        uint index;  
        (seed, index) = seed.random(100);
        if (i % 2 ==0 && j % 2 == 0) {
          if (i % 8 ==0 && j % 8 == 0 && index < _ratio2) {
            node.scale = '0.5'; // 1/2
            node.size = 512;
            for (uint k=0; k<64; k++) {
              filled[i + k % 8][j + k / 8] = true;
            }
          } else if (i % 4 ==0 && j % 4 == 0 && index < _ratio4) {
            node.scale = '0.25'; // 1/4
            node.size = 256;
            for (uint k=0; k<16; k++) {
              filled[i + k % 4][j + k / 4] = true;
            }
          } else if (index < _ratio8) {
            node.scale = '0.125'; // 1/8
            node.size = 128;
            filled[i+1][j] = true;
            filled[i][j+1] = true;
            filled[i+1][j+1] = true;
          }
        }
        nodesFixed[i][j] = node;
        count++;
      }
    }

    nodes = new Node[](count);
    count = 0;
    for (uint j = 0; j < 16; j++) {
      for (uint i = 0; i < 16; i++) {
        if (!filled[i][j]) {
          nodes[count++] = nodesFixed[i][j];
        }
      }
    }
  }
}
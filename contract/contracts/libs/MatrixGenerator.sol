// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import 'randomizer.sol/Randomizer.sol';
import '../interfaces/ILayoutGenerator.sol';

contract MatrixGenerator is ILayoutGenerator {
  using Randomizer for Randomizer.Seed;
  struct Props {
    uint ratio2;
    uint ratio4;
    uint ratio8;
  }

  function generate(
    Randomizer.Seed memory _seed,
    uint _props
  ) external pure override returns (Randomizer.Seed memory seed, Node[] memory nodes) {
    seed = _seed;
    Props memory props = Props(_props & 0xff, (_props / 0x100) & 0xff, (_props / 0x10000) & 0xff);

    Node[16][16] memory nodesFixed;
    bool[16][16] memory filled;
    uint count;

    for (uint j = 0; j < 16; j++) {
      for (uint i = 0; i < 16; i++) {
        if (filled[i][j]) {
          continue;
        }
        Node memory node;
        node.y = j * 64;
        node.x = i * 64;
        node.scale = '0.0625'; // 1/16
        node.size = 64;
        uint index;
        (seed, index) = seed.random(100);
        if (i % 2 == 0 && j % 2 == 0) {
          if (i % 8 == 0 && j % 8 == 0 && index < props.ratio2) {
            node.scale = '0.5'; // 1/2
            node.size = 512;
            for (uint k = 0; k < 64; k++) {
              filled[i + (k % 8)][j + k / 8] = true;
            }
          } else if (i % 4 == 0 && j % 4 == 0 && index < props.ratio4) {
            node.scale = '0.25'; // 1/4
            node.size = 256;
            for (uint k = 0; k < 16; k++) {
              filled[i + (k % 4)][j + k / 4] = true;
            }
          } else if (index < props.ratio8) {
            node.scale = '0.125'; // 1/8
            node.size = 128;
            filled[i + 1][j] = true;
            filled[i][j + 1] = true;
            filled[i + 1][j + 1] = true;
          }
        }
        filled[i][j] = false;
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

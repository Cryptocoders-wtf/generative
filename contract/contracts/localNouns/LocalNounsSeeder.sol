// SPDX-License-Identifier: GPL-3.0

/// @title The NounsToken pseudo-random seed generator

/*********************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *********************************/

pragma solidity ^0.8.6;

import { ILocalNounsSeeder } from './interfaces/ILocalNounsSeeder.sol';
import { INounsDescriptorMinimal } from './interfaces/INounsDescriptorMinimal.sol';

contract LocalNounsSeeder is ILocalNounsSeeder {
  /**
   * @notice Generate a pseudo-random Noun seed using the previous blockhash and noun ID.
   */
  function generateSeed(
    uint256 prefectureId,
    uint256 nounId,
    INounsDescriptorMinimal descriptor
  ) external view returns (Seed memory) {
    uint256 pseudorandomness = (block.number - 1) + nounId;

    uint256 accessoryCount = descriptor.accessoryCountInPrefecture(prefectureId % 100); // 1,2桁目：都道府県番号、3桁目以降：バージョン番号
    uint256 headCount = descriptor.headCountInPrefecture(prefectureId);

    uint256 accesoryPartId = descriptor.accessoryInPrefecture(prefectureId % 100, pseudorandomness % accessoryCount);
    uint256 headPartId = descriptor.headInPrefecture(prefectureId, pseudorandomness % headCount);

    return Seed({ background: 0, body: 0, accessory: uint48(accesoryPartId), head: uint48(headPartId), glasses: 0 });
  }
}

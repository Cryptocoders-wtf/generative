// SPDX-License-Identifier: MIT

/*
 * Helper methods for SVG generative.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import 'assetprovider.sol/ISVGHelper.sol';

contract SVGHelper is ISVGHelper {
  using Strings for uint16;

  struct Point {
    int16 x;
    int16 y;
    int16 r; // ratio (0 to 1024)
    bool c; // true:line, false:bezier
  }

  /**
   * Generate a SVG path from series of control points
   *
   * Note: It is possible to significantly improve this using assembly (see SVGPathDecoderA).
   */
  function pathFromPoints(uint[] memory points) external pure override returns (bytes memory path) {
    uint256 length = points.length;
    uint word;
    Point memory point;
    Point memory prev;
    Point memory next;
    for (uint256 i = 0; i < length; i++) {
      word = points[i];
      point.x = int16(uint16(word & 0xffff));
      point.y = int16(uint16((word >> 16) & 0xffff));
      point.r = int16(uint16((word >> 32) & 0xffff));
      point.c = ((word >> 48) & 0x1) == 0x1;
      word = points[(i + length - 1) % length];
      prev.x = int16(uint16(word & 0xffff));
      prev.y = int16(uint16((word >> 16) & 0xffff));
      int16 sx = (point.x + prev.x) / 2;
      int16 sy = (point.y + prev.y) / 2;
      if (i == 0) {
        path = abi.encodePacked('M', uint16(sx).toString(), ',', uint16(sy).toString());
      }

      word = points[(i + 1) % length];
      next.x = int16(uint16(word & 0xffff));
      next.y = int16(uint16((word >> 16) & 0xffff));
      int16 ex = (point.x + next.x) / 2;
      int16 ey = (point.y + next.y) / 2;
      if (point.c) {
        path = abi.encodePacked(
          path,
          'L',
          uint16(point.x).toString(),
          ',',
          uint16(point.y).toString(),
          ',',
          uint16(ex).toString(),
          ',',
          uint16(ey).toString()
        );
      } else {
        path = abi.encodePacked(
          path,
          'C',
          uint16(sx + int16((int(point.r) * int(point.x - sx)) / 1024)).toString(),
          ',',
          uint16(sy + int16((int(point.r) * int(point.y - sy)) / 1024)).toString(),
          ',',
          uint16(ex + int16((int(point.r) * int(point.x - ex)) / 1024)).toString(),
          ',',
          uint16(ey + int16((int(point.r) * int(point.y - ey)) / 1024)).toString(),
          ',',
          uint16(ex).toString(),
          ',',
          uint16(ey).toString()
        );
      }
    }
  }

  /**
   * Benchmarking
   */
  function generateSVGPart(
    IAssetProvider provider,
    uint256 _assetId
  ) external view override returns (string memory svgPart, string memory tag, uint256 gas) {
    gas = gasleft();
    (svgPart, tag) = provider.generateSVGPart(_assetId);
    gas -= gasleft();
  }
}

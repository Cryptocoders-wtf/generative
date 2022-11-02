// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import "trigonometry.sol/Trigonometry.sol";

library VectorLibrary {
  using Trigonometry for uint;

  struct Vector {
    int x; // fixed point * 0x8000
    int y; // fixed point * 0x8000
  }

  function newVector(int _x, int _y) internal pure returns(Vector memory vector) {
    vector.x = _x * 0x8000;
    vector.y = _y * 0x8000;
  }

  function newVectorWithAngle(int _angle, int _radius) internal pure returns(Vector memory vector) {
    uint angle = uint(_angle + 0x4000 << 64);
    vector.x = _radius * angle.cos() / 0x8000;
    vector.y = _radius * angle.sin() / 0x8000;
  }

  function div(Vector memory _vector, int _value) internal pure returns(Vector memory vector) {
    vector.x = _vector.x / _value;
    vector.y = _vector.y / _value;
  }

  function mul(Vector memory _vector, int _value) internal pure returns(Vector memory vector) {
    vector.x = _vector.x * _value;
    vector.y = _vector.y * _value;
  }

  function add(Vector memory _vector, Vector memory _vector2) internal pure returns(Vector memory vector) {
    vector.x = _vector.x + _vector2.x;
    vector.y = _vector.y + _vector2.y;
  }

  function rotate(Vector memory _vector, int _angle) internal pure returns(Vector memory vector) {
    uint angle = uint(_angle + 0x4000 << 64);
    int cos = angle.cos();
    int sin = angle.sin();
    vector.x = (cos * _vector.x - sin * _vector.y) / 0x8000;
    vector.y = (sin * _vector.x + cos * _vector.y) / 0x8000;
  }
}
// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import "bytes-array.sol/BytesArray.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

library Attribute {
  enum Attr {
    FILL, STROKE, STROKE_WIDTH
  }
  struct Struct {
    Attr attr;
    string value;
  }

  function fill(string memory _color) internal pure returns(Struct[] memory ctx) {
    ctx = new Struct[](1);
    ctx[0] = Struct(Attr.FILL, _color);
  }

  function fill(Struct[] memory _ctx, string memory _color) internal pure returns(Struct[] memory ctx) {
    ctx = _concat(_ctx, fill(_color));
  }

  function stroke(string memory _color, string memory _width) internal pure returns(Struct[] memory ctx) {
    ctx = new Struct[](2);
    ctx[0] = Struct(Attr.STROKE, _color);
    ctx[1] = Struct(Attr.STROKE_WIDTH, _width);
  }

  function stroke(Struct[] memory _ctx, string memory _color, string memory _width) internal pure returns(Struct[] memory ctx) {
    ctx = _concat(_ctx, stroke(_color, _width));
  }

  function _concat(Struct[] memory _ctx0, Struct[] memory _ctx1) internal pure returns(Struct[] memory ctx) {
    ctx = new Struct[](_ctx0.length + _ctx1.length);
    for (uint i=0; i<_ctx0.length; i++) {
      ctx[i] = _ctx0[i];
    }
    for (uint i=0; i<_ctx1.length; i++) {
      ctx[i + _ctx0.length] = _ctx1[i];      
    }
  }

  function _append(Attribute.Struct[] memory _ctxs, bytes memory _svg) internal pure returns(bytes memory svg) {
    svg = _svg;
    for (uint i=0; i<_ctxs.length; i++) {
      Attribute.Struct memory ctx = _ctxs[i];
      if (ctx.attr == Attribute.Attr.FILL) {
        svg = abi.encodePacked(svg, '" fill="', ctx.value);      
      } else if (ctx.attr == Attribute.Attr.STROKE) {
        svg = abi.encodePacked(svg, '" stroke="', ctx.value);      
      } else if (ctx.attr == Attribute.Attr.STROKE_WIDTH) {
        svg = abi.encodePacked(svg, '" stroke-width="', ctx.value);      
      }      
    }
    svg = abi.encodePacked(svg, '" />');
  }
}

library SVG {
  using BytesArray for bytes[];
  using Strings for uint;
  using Attribute for Attribute.Struct[];

  function path(bytes memory _path, string memory _id) internal pure returns(bytes memory svg) {
    svg = abi.encodePacked(
      '<path id="', _id, '" d="', _path, '"/>\n'
    );
  }

  function group(bytes[] memory _parts, string memory _id) internal pure returns(bytes memory svg) {
    svg = abi.encodePacked(
      '<g id="', _id, '">', _parts.packed(), '</g>\n'
    );
  }

  function fill(bytes memory _svg, string memory _value) internal pure returns(bytes memory svg) {
    svg = abi.encodePacked(
      '<g fill="', _value, '">', _svg, '</g>\n'
    );
  }

  function circle(int _cx, int _cy, int _radius) internal pure returns(bytes memory svg) {
    svg = abi.encodePacked(
        '<circle cx="', uint(_cx).toString(),'" cy="', uint(_cy).toString(),'" r="', uint(_radius).toString(),'" />'
    );
  }

  function circle(int _cx, int _cy, int _radius, Attribute.Struct[] memory _ctxs) internal pure returns(bytes memory svg) {
    svg = _ctxs._append(abi.encodePacked(
        '<circle cx="', uint(_cx).toString(),'" cy="', uint(_cy).toString(),'" r="', uint(_radius).toString()
    ));
  }

  // "_mask" will be added to the id
  function mask(bytes memory _svg, string memory _id) internal pure returns(bytes memory svg) {
    svg = abi.encodePacked(
      '<mask id="', _id ,'_mask">'
      '<rect x="0" y="0" width="100%" height="100%" fill="white"/>'
      '<g fill="black">',
      _svg,
      '</g>'
      '</mask>\n'
    );
  }
}
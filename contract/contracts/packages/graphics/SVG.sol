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
import "hardhat/console.sol";

library Attribute {
  enum Attr {
    FILL, STROKE, STROKE_WIDTH, ID
  }
  struct Struct {
    Attr attr;
    string value;
  }

  function id(string memory _value) internal pure returns(Struct[] memory ctx) {
    ctx = new Struct[](1);
    ctx[0] = Struct(Attr.ID, _value);
  }

  function id(Struct[] memory _ctx, string memory _value) internal pure returns(Struct[] memory ctx) {
    ctx = _concat(_ctx, id(_value));
  }

  function fill(string memory _value) internal pure returns(Struct[] memory ctx) {
    ctx = new Struct[](1);
    ctx[0] = Struct(Attr.FILL, _value);
  }

  function fill(Struct[] memory _ctx, string memory _value) internal pure returns(Struct[] memory ctx) {
    ctx = _concat(_ctx, fill(_value));
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
      if (ctx.attr == Attribute.Attr.ID) {
        svg = abi.encodePacked(svg, '" id="', ctx.value);      
      } else if (ctx.attr == Attribute.Attr.FILL) {
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
  using Strings for uint;
  struct Attrib {
    string key;
    string value;
  }

  struct Tag {
    bytes head;
    bytes tail;
    Attrib[] attrs;    
  }

  function path(bytes memory _path) internal pure returns(Tag memory tag) {
    tag.head = abi.encodePacked('<path d="', _path); 
    tag.tail = bytes('"/>\n');
  }

  function circle(int _cx, int _cy, int _radius) internal pure returns(Tag memory tag) {
    tag.head = abi.encodePacked('<circle cx="', uint(_cx).toString(),'" cy="', uint(_cy).toString(),'" r="', uint(_radius).toString());
    tag.tail = '"/>\n';
  }

  function group(bytes memory _elements) internal pure returns(Tag memory tag) {
    tag.head = abi.encodePacked('<g x_x="x'); // HACK: dummy header for trailing '"'
    tag.tail = abi.encodePacked('">', _elements, '</g>\n');
  }

  function mask(bytes memory _elements) internal pure returns(Tag memory tag) {
    tag.head = abi.encodePacked('<mask x_x="x'); // HACK: dummy header for trailing '"'
    tag.tail = abi.encodePacked(
      '">' 
      '<rect x="0" y="0" width="100%" height="100%" fill="black"/>'
      '<g fill="white">',
      _elements,
      '</g>' 
      '</mask>\n');
  }

  function stencil(bytes memory _elements) internal pure returns(Tag memory tag) {
    tag.head = abi.encodePacked('<mask x_x="x'); // HACK: dummy header for trailing '"'
    tag.tail = abi.encodePacked(
      '">' 
      '<rect x="0" y="0" width="100%" height="100%" fill="white"/>'
      '<g fill="black">',
      _elements,
      '</g>' 
      '</mask>\n');
  }

  function _append(Tag memory _tag, Attrib memory _attr) internal pure returns(Tag memory tag) {
    tag.head = _tag.head;
    tag.tail = _tag.tail;
    tag.attrs = new Attrib[](_tag.attrs.length + 1);
    for (uint i=0; i<_tag.attrs.length; i++) {
      tag.attrs[i] = _tag.attrs[i];
    }
    tag.attrs[_tag.attrs.length] = _attr;   
  }

  function _append2(Tag memory _tag, Attrib memory _attr, Attrib memory _attr2) internal pure returns(Tag memory tag) {
    tag.head = _tag.head;
    tag.tail = _tag.tail;
    tag.attrs = new Attrib[](_tag.attrs.length + 2);
    for (uint i=0; i<_tag.attrs.length; i++) {
      tag.attrs[i] = _tag.attrs[i];
    }
    tag.attrs[_tag.attrs.length] = _attr;   
    tag.attrs[_tag.attrs.length+1] = _attr2;   
  }

  function id(Tag memory _tag, string memory _value) internal pure returns(Tag memory tag) {
    tag = _append(_tag, Attrib("id", _value));
  }

  function fill(Tag memory _tag, string memory _value) internal pure returns(Tag memory tag) {
    tag = _append(_tag, Attrib("fill", _value));
  }

  function stroke(Tag memory _tag, string memory _color, uint _width) internal pure returns(Tag memory tag) {
    tag = _append2(_tag, Attrib("stroke", _color), Attrib("stroke-width", _width.toString()));
  }

  function svg(Tag memory _tag) internal pure returns (bytes memory output) {
    output = _tag.head;
    for (uint i=0; i<_tag.attrs.length; i++) {
      Attrib memory attr = _tag.attrs[i];
      output = abi.encodePacked(output, '" ', attr.key ,'="', attr.value);      
    }
    output = abi.encodePacked(output, _tag.tail);
  }
}

library SVG_OLD {
  using BytesArray for bytes[];
  using Strings for uint;
  using Attribute for Attribute.Struct[];


  function path(bytes memory _path) internal pure returns(bytes memory svg) {
    svg = abi.encodePacked(
      '<path d="', _path, '"/>\n'
    );
  }

  function path(bytes memory _path, Attribute.Struct[] memory _ctxs) internal pure returns(bytes memory svg) {
    svg = _ctxs._append(abi.encodePacked(
      '<path d="', _path
    ));
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
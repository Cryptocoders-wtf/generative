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

library SVG {
  using Strings for uint;
  using BytesArray for bytes[];

  struct Attribute {
    string key;
    string value;
  }

  struct Element {
    bytes head;
    bytes tail;
    Attribute[] attrs;    
  }

  function path(bytes memory _path) internal pure returns(Element memory tag) {
    tag.head = abi.encodePacked('<path d="', _path); 
    tag.tail = bytes('"/>\n');
  }

  function circle(int _cx, int _cy, int _radius) internal pure returns(Element memory tag) {
    tag.head = abi.encodePacked('<circle cx="', uint(_cx).toString(),'" cy="', uint(_cy).toString(),'" r="', uint(_radius).toString());
    tag.tail = '"/>\n';
  }

  function rect(int _x, int _y, uint _width, uint _height) internal pure returns(Element memory tag) {
    tag.head = abi.encodePacked('<rect x="', uint(_x).toString(),'" y="', uint(_y).toString(),
                                '" width="', _width.toString(), '" height="', _height.toString());
    tag.tail = '"/>\n';
  }

  function rect() internal pure returns(Element memory tag) {
    tag.head = abi.encodePacked('<rect width="100%" height="100%');
    tag.tail = '"/>\n';
  }

  function use(string memory _id) internal pure returns(Element memory tag) {
    tag.head = abi.encodePacked('<use href="#', _id);
    tag.tail = '"/>\n';
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function packed(Element[4] memory _tags) internal pure returns(bytes memory output) {
    bytes[] memory svgs = new bytes[](4);
    svgs[0] = svg(_tags[0]);
    svgs[1] = svg(_tags[1]);
    svgs[2] = svg(_tags[2]);
    svgs[3] = svg(_tags[3]);
    output = svgs.packed();
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function packed(Element[3] memory _tags) internal pure returns(bytes memory output) {
    bytes[] memory svgs = new bytes[](3);
    svgs[0] = svg(_tags[0]);
    svgs[1] = svg(_tags[1]);
    svgs[2] = svg(_tags[2]);
    output = svgs.packed();
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function packed(Element[2] memory _tags) internal pure returns(bytes memory output) {
    bytes[] memory svgs = new bytes[](2);
    svgs[0] = svg(_tags[0]);
    svgs[1] = svg(_tags[1]);
    output = svgs.packed();
  }

  function packed(Element[] memory _tags) internal pure returns(bytes memory output) {
    bytes[] memory svgs = new bytes[](_tags.length);
    for (uint i=0; i<_tags.length; i++) {
      svgs[i] = svg(_tags[i]);
    }
    output = svgs.packed();
  }

  function group(bytes memory _elements) internal pure returns(Element memory tag) {
    tag.head = abi.encodePacked('<g x_x="x'); // HACK: dummy header for trailing '"'
    tag.tail = abi.encodePacked('">', _elements, '</g>\n');
  }

  function group(Element memory _tag) internal pure returns(Element memory tag) {
    tag = group(svg(_tag));
  }

  function group(Element[] memory _tags) internal pure returns(Element memory tag) {
    tag = group(packed(_tags));
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function group(Element[2] memory _tags) internal pure returns(Element memory tag) {
    tag = group(packed(_tags));
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function group(Element[3] memory _tags) internal pure returns(Element memory tag) {
    tag = group(packed(_tags));
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function group(Element[4] memory _tags) internal pure returns(Element memory tag) {
    tag = group(packed(_tags));
  }

  function list(Element[] memory _tags) internal pure returns(Element memory tag) {
    tag.tail = packed(_tags);
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function list(Element[2] memory _tags) internal pure returns(Element memory tag) {
    tag.tail = packed(_tags);
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function list(Element[3] memory _tags) internal pure returns(Element memory tag) {
    tag.tail = packed(_tags);
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function list(Element[4] memory _tags) internal pure returns(Element memory tag) {
    tag.tail = packed(_tags);
  }

  function mask(bytes memory _elements) internal pure returns(Element memory tag) {
    tag.head = abi.encodePacked('<mask x_x="x'); // HACK: dummy header for trailing '"'
    tag.tail = abi.encodePacked(
      '">' 
      '<rect x="0" y="0" width="100%" height="100%" fill="black"/>'
      '<g fill="white">',
      _elements,
      '</g>' 
      '</mask>\n');
  }

  function mask(Element memory _tag) internal pure returns(Element memory tag) {
    tag = mask(svg(_tag));
  }

  function stencil(bytes memory _elements) internal pure returns(Element memory tag) {
    tag.head = abi.encodePacked('<mask x_x="x'); // HACK: dummy header for trailing '"'
    tag.tail = abi.encodePacked(
      '">' 
      '<rect x="0" y="0" width="100%" height="100%" fill="white"/>'
      '<g fill="black">',
      _elements,
      '</g>' 
      '</mask>\n');
  }

  function stencil(Element memory _tag) internal pure returns(Element memory tag) {
    tag = stencil(svg(_tag));
  }

  function _append(Element memory _tag, Attribute memory _attr) internal pure returns(Element memory tag) {
    tag.head = _tag.head;
    tag.tail = _tag.tail;
    tag.attrs = new Attribute[](_tag.attrs.length + 1);
    for (uint i=0; i<_tag.attrs.length; i++) {
      tag.attrs[i] = _tag.attrs[i];
    }
    tag.attrs[_tag.attrs.length] = _attr;   
  }

  function _append2(Element memory _tag, Attribute memory _attr, Attribute memory _attr2) internal pure returns(Element memory tag) {
    tag.head = _tag.head;
    tag.tail = _tag.tail;
    tag.attrs = new Attribute[](_tag.attrs.length + 2);
    for (uint i=0; i<_tag.attrs.length; i++) {
      tag.attrs[i] = _tag.attrs[i];
    }
    tag.attrs[_tag.attrs.length] = _attr;   
    tag.attrs[_tag.attrs.length+1] = _attr2;   
  }

  function id(Element memory _tag, string memory _value) internal pure returns(Element memory tag) {
    tag = _append(_tag, Attribute("id", _value));
  }

  function fill(Element memory _tag, string memory _value) internal pure returns(Element memory tag) {
    tag = _append(_tag, Attribute("fill", _value));
  }

  function transform(Element memory _tag, string memory _value) internal pure returns(Element memory tag) {
    tag = _append(_tag, Attribute("transform", _value));
  }

  function mask(Element memory _tag, string memory _value) internal pure returns(Element memory tag) {
    tag = _append(_tag, Attribute("mask", string(abi.encodePacked('url(#', _value,')'))));
  }

  function stroke(Element memory _tag, string memory _color, uint _width) internal pure returns(Element memory tag) {
    tag = _append2(_tag, Attribute("stroke", _color), Attribute("stroke-width", _width.toString()));
  }

  function svg(Element memory _tag) internal pure returns (bytes memory output) {
    if (_tag.head.length > 0) {
      output = _tag.head;
      for (uint i=0; i<_tag.attrs.length; i++) {
        Attribute memory attr = _tag.attrs[i];
        output = abi.encodePacked(output, '" ', attr.key ,'="', attr.value);      
      }
    } else {
      require(_tag.attrs.length == 0, "Attributes on list");
    }
    output = abi.encodePacked(output, _tag.tail);
  }

  function document(string memory _viewBox, bytes memory _defs, bytes memory _body) internal pure returns (bytes memory output) {
    output = abi.encodePacked(
      '<svg viewBox="', _viewBox, '"'
      ' xmlns="http://www.w3.org/2000/svg">\n'
    );
    if (_defs.length > 0) {
      output = abi.encodePacked(output, '<defs>\n', _defs, '</defs>\n');
    }
    output = abi.encodePacked(output, _body, '</svg>\n');
  }
}

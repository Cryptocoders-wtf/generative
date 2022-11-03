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
import "hardhat/console.sol";

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

  function rect(int _x, int _y, uint _width, uint _height) internal pure returns(Tag memory tag) {
    tag.head = abi.encodePacked('<rect x="', uint(_x).toString(),'" y="', uint(_y).toString(),
                                '" width="', _width.toString(), '" height="', _height.toString());
    tag.tail = '"/>\n';
  }

  function rect() internal pure returns(Tag memory tag) {
    tag.head = abi.encodePacked('<rect width="100%" height="100%');
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

  function mask(Tag memory _tag, string memory _value) internal pure returns(Tag memory tag) {
    tag = _append(_tag, Attrib("mask", string(abi.encodePacked('url(#', _value,')'))));
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

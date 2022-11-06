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

  function path(bytes memory _path) internal pure returns(Element memory element) {
    element.head = abi.encodePacked('<path d="', _path); 
    element.tail = bytes('"/>\n');
  }

  function circle(int _cx, int _cy, int _radius) internal pure returns(Element memory element) {
    element.head = abi.encodePacked('<circle cx="', uint(_cx).toString(),'" cy="', uint(_cy).toString(),'" r="', uint(_radius).toString());
    element.tail = '"/>\n';
  }

  function rect(int _x, int _y, uint _width, uint _height) internal pure returns(Element memory element) {
    element.head = abi.encodePacked('<rect x="', uint(_x).toString(),'" y="', uint(_y).toString(),
                                '" width="', _width.toString(), '" height="', _height.toString());
    element.tail = '"/>\n';
  }

  function rect() internal pure returns(Element memory element) {
    element.head = abi.encodePacked('<rect width="100%" height="100%');
    element.tail = '"/>\n';
  }

  function stop(uint ratio) internal pure returns(Element memory element) {
    element.head = abi.encodePacked('<stop offset="', ratio.toString(), '%');
    element.tail = '"/>\n';
  }

  function use(string memory _id) internal pure returns(Element memory element) {
    element.head = abi.encodePacked('<use href="#', _id);
    element.tail = '"/>\n';
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function packed(Element[4] memory _elements) internal pure returns(bytes memory output) {
    bytes[] memory svgs = new bytes[](4);
    svgs[0] = svg(_elements[0]);
    svgs[1] = svg(_elements[1]);
    svgs[2] = svg(_elements[2]);
    svgs[3] = svg(_elements[3]);
    output = svgs.packed();
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function packed(Element[3] memory _elements) internal pure returns(bytes memory output) {
    bytes[] memory svgs = new bytes[](3);
    svgs[0] = svg(_elements[0]);
    svgs[1] = svg(_elements[1]);
    svgs[2] = svg(_elements[2]);
    output = svgs.packed();
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function packed(Element[2] memory _elements) internal pure returns(bytes memory output) {
    bytes[] memory svgs = new bytes[](2);
    svgs[0] = svg(_elements[0]);
    svgs[1] = svg(_elements[1]);
    output = svgs.packed();
  }

  function packed(Element[] memory _elements) internal pure returns(bytes memory output) {
    bytes[] memory svgs = new bytes[](_elements.length);
    for (uint i=0; i<_elements.length; i++) {
      svgs[i] = svg(_elements[i]);
    }
    output = svgs.packed();
  }

  function linearGradient(bytes memory _elements, string memory _value) internal pure returns(Element memory element) {
    element.head = abi.encodePacked('<linearGradient id="', _value); 
    element.tail = abi.encodePacked('">', _elements, '</linearGradient>\n');
  }

  function linearGradient(Element memory _element, string memory _value) internal pure returns(Element memory element) {
    element = linearGradient(svg(_element), _value);
  }

  function linearGradient(Element[] memory _elements, string memory _value) internal pure returns(Element memory element) {
    element = linearGradient(packed(_elements), _value);
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function linearGradient(Element[2] memory _elements, string memory _value) internal pure returns(Element memory element) {
    element = linearGradient(packed(_elements), _value);
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function linearGradient(Element[3] memory _elements, string memory _value) internal pure returns(Element memory element) {
    element = linearGradient(packed(_elements), _value);
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function linearGradient(Element[4] memory _elements, string memory _value) internal pure returns(Element memory element) {
    element = linearGradient(packed(_elements), _value);
  }

  function group(bytes memory _elements) internal pure returns(Element memory element) {
    element.head = abi.encodePacked('<g x_x="x'); // HACK: dummy header for trailing '"'
    element.tail = abi.encodePacked('">', _elements, '</g>\n');
  }

  function group(Element memory _element) internal pure returns(Element memory element) {
    element = group(svg(_element));
  }

  function group(Element[] memory _elements) internal pure returns(Element memory element) {
    element = group(packed(_elements));
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function group(Element[2] memory _elements) internal pure returns(Element memory element) {
    element = group(packed(_elements));
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function group(Element[3] memory _elements) internal pure returns(Element memory element) {
    element = group(packed(_elements));
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function group(Element[4] memory _elements) internal pure returns(Element memory element) {
    element = group(packed(_elements));
  }

  function list(Element[] memory _elements) internal pure returns(Element memory element) {
    element.tail = packed(_elements);
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function list(Element[2] memory _elements) internal pure returns(Element memory element) {
    element.tail = packed(_elements);
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function list(Element[3] memory _elements) internal pure returns(Element memory element) {
    element.tail = packed(_elements);
  }

  // HACK: Solidity does not support literal expression of dynamic array yet
  function list(Element[4] memory _elements) internal pure returns(Element memory element) {
    element.tail = packed(_elements);
  }

  function mask(bytes memory _elements) internal pure returns(Element memory element) {
    element.head = abi.encodePacked('<mask x_x="x'); // HACK: dummy header for trailing '"'
    element.tail = abi.encodePacked(
      '">' 
      '<rect x="0" y="0" width="100%" height="100%" fill="black"/>'
      '<g fill="white">',
      _elements,
      '</g>' 
      '</mask>\n');
  }

  function mask(Element memory _element) internal pure returns(Element memory element) {
    element = mask(svg(_element));
  }

  function stencil(bytes memory _elements) internal pure returns(Element memory element) {
    element.head = abi.encodePacked('<mask x_x="x'); // HACK: dummy header for trailing '"'
    element.tail = abi.encodePacked(
      '">' 
      '<rect x="0" y="0" width="100%" height="100%" fill="white"/>'
      '<g fill="black">',
      _elements,
      '</g>' 
      '</mask>\n');
  }

  function stencil(Element memory _element) internal pure returns(Element memory element) {
    element = stencil(svg(_element));
  }

  function _append(Element memory _element, Attribute memory _attr) internal pure returns(Element memory element) {
    element.head = _element.head;
    element.tail = _element.tail;
    element.attrs = new Attribute[](_element.attrs.length + 1);
    for (uint i=0; i<_element.attrs.length; i++) {
      element.attrs[i] = _element.attrs[i];
    }
    element.attrs[_element.attrs.length] = _attr;   
  }

  function _append2(Element memory _element, Attribute memory _attr, Attribute memory _attr2) internal pure returns(Element memory element) {
    element.head = _element.head;
    element.tail = _element.tail;
    element.attrs = new Attribute[](_element.attrs.length + 2);
    for (uint i=0; i<_element.attrs.length; i++) {
      element.attrs[i] = _element.attrs[i];
    }
    element.attrs[_element.attrs.length] = _attr;   
    element.attrs[_element.attrs.length+1] = _attr2;   
  }

  function id(Element memory _element, string memory _value) internal pure returns(Element memory element) {
    element = _append(_element, Attribute("id", _value));
  }

  function fill(Element memory _element, string memory _value) internal pure returns(Element memory element) {
    element = _append(_element, Attribute("fill", _value));
  }

  function stopColor(Element memory _element, string memory _value) internal pure returns(Element memory element) {
    element = _append(_element, Attribute("stop-color", _value));
  }

  function x1(Element memory _element, uint _value) internal pure returns(Element memory element) {
    element = _append(_element, Attribute("x1", _value.toString()));
  }

  function x2(Element memory _element, uint _value) internal pure returns(Element memory element) {
    element = _append(_element, Attribute("x2", _value.toString()));
  }

  function y1(Element memory _element, uint _value) internal pure returns(Element memory element) {
    element = _append(_element, Attribute("y1", _value.toString()));
  }

  function y2(Element memory _element, uint _value) internal pure returns(Element memory element) {
    element = _append(_element, Attribute("y2", _value.toString()));
  }

  function fillRef(Element memory _element, string memory _value) internal pure returns(Element memory element) {
    element = _append(_element, Attribute("fill", string(abi.encodePacked('url(#', _value, ')'))));
  }

  function style(Element memory _element, string memory _value) internal pure returns(Element memory element) {
    element = _append(_element, Attribute("style", _value));
  }

  function transform(Element memory _element, string memory _value) internal pure returns(Element memory element) {
    element = _append(_element, Attribute("transform", _value));
  }

  function mask(Element memory _element, string memory _value) internal pure returns(Element memory element) {
    element = _append(_element, Attribute("mask", string(abi.encodePacked('url(#', _value,')'))));
  }

  function stroke(Element memory _element, string memory _color, uint _width) internal pure returns(Element memory element) {
    element = _append2(_element, Attribute("stroke", _color), Attribute("stroke-width", _width.toString()));
  }

  function svg(Element memory _element) internal pure returns (bytes memory output) {
    if (_element.head.length > 0) {
      output = _element.head;
      for (uint i=0; i<_element.attrs.length; i++) {
        Attribute memory attr = _element.attrs[i];
        output = abi.encodePacked(output, '" ', attr.key ,'="', attr.value);      
      }
    } else {
      require(_element.attrs.length == 0, "Attributes on list");
    }
    output = abi.encodePacked(output, _element.tail);
  }

  function document(string memory _viewBox, bytes memory _defs, bytes memory _body) internal pure returns (string memory) {
    bytes memory output = abi.encodePacked(
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<svg viewBox="', _viewBox, '"'
      ' xmlns="http://www.w3.org/2000/svg">\n'
    );
    if (_defs.length > 0) {
      output = abi.encodePacked(output, '<defs>\n', _defs, '</defs>\n');
    }
    output = abi.encodePacked(output, _body, '</svg>\n');
    return string(output);
  }
}

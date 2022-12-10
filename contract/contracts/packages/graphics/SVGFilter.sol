// SPDX-License-Identifier: MIT

/*
 * This is a part of fully-on-chain.sol, a npm package that allows developers
 * to create fully on-chain generative art.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import './SVG.sol';

library SVGFilter {
  function rouchPaper(string memory id) internal pure returns (SVG.Element memory elem) {
    elem.head = abi.encodePacked('<filter style="color-interpolation-filters:sRGB;" id="', id);
    elem.tail = bytes(
      '" >'
        '<feTurbulence type="fractalNoise" baseFrequency="0.04" numOctaves="5" seed="0" result="result4" id="feTurbulence2072" />'
        '<feDisplacementMap in="SourceGraphic" in2="result4" yChannelSelector="G" xChannelSelector="R" scale="10" result="result3" id="feDisplacementMap2074" />'
        '<feDiffuseLighting lighting-color="rgb(233,230,215)" diffuseConstant="1" surfaceScale="2" result="result1" in="result4" id="feDiffuseLighting2078">'
          '<feDistantLight azimuth="235" elevation="40" id="feDistantLight2076" />'
        '</feDiffuseLighting>'
        '<feComposite operator="in" in="result3" in2="result1" result="result2" id="feComposite2080" />'
        '<feComposite in2="result1" result="result5" operator="arithmetic" k1="1.7" id="feComposite2082" />'
        '<feBlend in="result5" in2="result3" mode="normal" id="feBlend2084" />'
      '</filter>'
    );
  }
}
pragma solidity ^0.8.6;

import '../../packages/graphics/Path.sol';
import '../../packages/graphics/SVG.sol';
import '../../packages/graphics/Text.sol';

import '../interfaces/IMessageStoreV2.sol';
import '../../packages/graphics/IFontProvider.sol';
import '@openzeppelin/contracts/utils/math/Math.sol';

contract MessageStoreV2 is IMessageStoreV2 {
  using SVG for SVG.Element;
  using TX for string;
  
  // fontName -> FontProvider
  mapping(string => IFontProvider) public fonts;

  uint256 public nextPartIndex = 1;
  mapping(uint256 => Asset) public partsList;

  function getAsset(uint256 index) external view returns (Asset memory) {
    return partsList[index];
  }
  
  function registerFont(string memory fontName, IFontProvider fontProvider) external {
    fonts[fontName] = fontProvider;
  }

  function register(Asset memory asset) external returns (uint256) {
    require(fonts[asset.fontName] != IFontProvider(address(0)), "Font not registered");
    // nextPartIndex is 1-based
    partsList[nextPartIndex] = asset;
    nextPartIndex++;
    return nextPartIndex - 1;
  }

  function generateSVGBody(uint256 id) internal view returns (bytes memory output) {
    Asset memory asset = partsList[id];
    Box memory box;
    box.w = 1024;
    box.h = 1024;
    output = generateSVGBody(asset.message, asset.color, asset.fontName, box);
  }

  // for provider
  function getSVGBody(uint256 index) external view override returns (bytes memory output) {
    output = generateSVGBody(index);
  }

  function getSVGBodyFromAsset(
    string memory message,
    string memory color,
    string memory fontName,
    Box memory box
  ) external view override returns (bytes memory output) {
    output = generateSVGBody(message, color, fontName, box);
  }

  function getSVG(uint256 index) external view override returns (string memory output) {
    SVG.Element[] memory samples = new SVG.Element[](0);

    output = SVG.document('0 0 1024 1024', SVG.list(samples).svg(), generateSVGBody(index));
  }

  // for web
  function getSVGMessage(
    string memory message,
    string memory color,
    string memory fontName,
    Box memory box
  ) external view override returns (string memory output) {
    SVG.Element[] memory samples = new SVG.Element[](1);
    output = SVG.document('0 0 1024 1024', SVG.list(samples).svg(), generateSVGBody(message, color, fontName, box));
  }

  function test(string memory message) external view returns (string[] memory output) {
    output = Text.split(message, 0x0a);
  }

  function generateSVGBody(
    string memory message,
    string memory color,
    string memory fontName,
    Box memory box
  ) internal view returns (bytes memory output) {
    string[] memory messages = Text.split(message, 0x0a); // split \n
    SVG.Element[] memory elements = new SVG.Element[](messages.length);

    IFontProvider font = fonts[fontName];

    // default w scale 1/4
    uint256 maxWidth = box.w * 4;
    for (uint256 i = 0; i < messages.length; i++) {
      uint256 width = SVG.textWidth(font, messages[i]);
      if (width > maxWidth) {
        maxWidth = width;
      }
      elements[i] = SVG.text(font, messages[i]).transform(TX.translate(0, int(font.height() * i)));
    }
    /*
    uint256 scaleW = (box.w * 1000) / maxWidth;
    uint256 maxHeight = font.height() * messages.length;
    uint256 scaleH = (box.h * 1000) / maxHeight;
    uint256 scale = Math.min(scaleW, scaleH);
    */
    uint256 scale = Math.min((box.w * 1000) / maxWidth, (box.h * 1000) / (font.height() * messages.length));

    SVG.Element memory tmp = SVG.group(elements).transform(TX.scale1000(scale));
    tmp = tmp.fill(color);

    SVG.Element[] memory lists = new SVG.Element[](1);
    lists[0] = tmp;

    output = SVG.list(lists).svg();
  }

  function getMessage(uint256 index) external view override returns (string memory output) {
      Asset memory asset = partsList[index];
      output = asset.message;
  }

  function isFontRegistered(string memory fontName) public view returns (bool) {
    return fonts[fontName] != IFontProvider(address(0));
  }

  function getNextPartIndex() public view override returns (uint256) {
    return nextPartIndex;
  }

}

pragma solidity ^0.8.6;

import '../../packages/graphics/Path.sol';
import '../../packages/graphics/SVG.sol';
import '../../packages/graphics/Text.sol';

import '../interfaces/IMessageStoreV1.sol';
import '../../packages/graphics/IFontProvider.sol';

contract MessageStoreV1 is IMessageStoreV1 {
    using SVG for SVG.Element;
    using TX for string;

    IFontProvider public immutable font;

    uint256 private nextPartIndex = 1;
    mapping(uint256 => Asset) private partsList;
    
    constructor(IFontProvider _font) {
        font = _font;
    }

    function register(Asset memory asset) external returns (uint256) {
        partsList[nextPartIndex] = asset;
        nextPartIndex++;
        return nextPartIndex - 1;
    }
    function generateSVGBody(uint256 id) internal view returns (bytes memory output) {
        Asset memory asset = partsList[id];
        SVG.Element[] memory elements = new SVG.Element[](1);
        /*        
        SVG.Element memory tmp = SVG.group([
                                            SVG.text(font, asset.message),
                                            SVG.text(font, asset.message)
                                            ]).transform(TX.scale1000(240));
        */
        SVG.Element memory tmp = SVG.text(font, asset.message).transform(TX.scale1000(240));
        tmp = tmp.fill(asset.color);
        elements[0] = tmp;
        
        output = SVG.list(elements).svg();
    }

    function getSVGBody(uint256 index) external view override returns (bytes memory output) {
        output = generateSVGBody(index);
    }

    function getSVG(uint256 index) external view override returns (string memory output) {
        SVG.Element[] memory samples = new SVG.Element[](0);

        output = SVG.document('0 0 1024 1024', SVG.list(samples).svg(), generateSVGBody(index));
    }
    

    function getSVGMessage(string memory message, string memory color) external view override returns (string memory output) {
        SVG.Element[] memory samples = new SVG.Element[](1);

        output = SVG.document('0 0 1024 1024', SVG.list(samples).svg(), generateSVGBody(message, color));
    }

    function test(string memory message) external view returns (string[] memory output) {
        output = Text.split(message, 0x0a);
    }

    function generateSVGBody(string memory message, string memory color) internal view returns (bytes memory output) {
        string[] memory messages = Text.split(message, 0x0a); // \n
        SVG.Element[] memory elements = new SVG.Element[](messages.length);
        
        uint256 maxWidth = 1024 * 4;
        for (uint256 i = 0; i < messages.length; i++) {
            uint256 width = SVG.textWidth(font, messages[i]);
            if (width > maxWidth) {
                maxWidth = width;
            }
            elements[i] = SVG.text(font, messages[i]).transform(TX.translate(0, int(1024 * i)));
        }

        uint256 scale = 1024 * 1000 / maxWidth;
            
        SVG.Element memory tmp = SVG.group(elements).transform(TX.scale1000(scale));
        tmp = tmp.fill(color);

        SVG.Element[] memory lists =  new SVG.Element[](1);
        lists[0] = tmp;
        
        output = SVG.list(lists).svg();
    }
    
}

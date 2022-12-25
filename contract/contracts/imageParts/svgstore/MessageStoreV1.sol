pragma solidity ^0.8.6;

import '../../packages/graphics/Path.sol';
import '../../packages/graphics/SVG.sol';

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

}

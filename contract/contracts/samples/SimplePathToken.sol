// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import '../packages/ERC721P2P/ERC721AP2P.sol';
import { Base64 } from 'base64-sol/base64.sol';
import 'randomizer.sol/Randomizer.sol';

import '../packages/graphics/Path.sol';
import '../packages/graphics/SVG.sol';

contract SimplePathToken is ERC721AP2P {
  using Randomizer for Randomizer.Seed;
  using Strings for uint256;
  using Strings for uint16;
  using Vector for Vector.Struct;
  using Path for uint[];
  using SVG for SVG.Element;

  uint public nextTokenId;
  
  struct Props {
    uint count; // number of spikes
    uint length; // relative length of each valley (percentile)
  }

  // To be specified by the concrete contract
  string public description;
  uint public mintPrice;
  uint public mintLimit;

  constructor(
    string memory _title,
    string memory _shortTitle
  ) ERC721A(_title, _shortTitle) {
    description = 'Simple Path Token';
    mintLimit = 1e50;
    
  }

  function setDescription(string memory _description) external onlyOwner {
    description = _description;
  }

  function setMintPrice(uint256 _price) external onlyOwner {
    mintPrice = _price;
  }

  function tokenName(uint256 _tokenId) internal pure returns (string memory) {
    return string(abi.encodePacked('Message Token V1 ', _tokenId.toString()));
  }

  function mint() public payable virtual returns (uint256 tokenId) {
    require(nextTokenId < mintLimit, 'Sold out');
    _safeMint(msg.sender, 1);

    return nextTokenId++;
  }

  function mintPriceFor(address) public view virtual returns (uint256) {
    return mintPrice;
  }

  function totalSupply() public view override returns (uint256) {
    return nextTokenId;
  }
  // for graphics

  string constant SVGHeader =
    '<svg viewBox="0 0 1024 1024'
    '"  xmlns="http://www.w3.org/2000/svg">\n'
    '<g>\n';
  function debugGenerateSVG(uint256 _assetId) external pure returns (string memory) {
    string memory svgPart = generateSVGPart(_assetId);
    return
      string(
        abi.encodePacked(
          SVGHeader,
          svgPart,
          '</g>\n'
          '</svg>\n'
        )
      );
  }

  function generatePath(Props memory _props) public pure returns (bytes memory path) {
    uint count = _props.count;
    int radius = 511; // We want to fill the whole viewbox (1024 x 1024)
    int length = int(_props.length);
    Vector.Struct memory center = Vector.vector(512, 512); // center of the viewbox
    uint[] memory points = new uint[](count * 2);
    for (uint i = 0; i < count * 2; i += 2) {
      int angle = (Vector.PI2 * int(i)) / int(count) / 2;
      Vector.Struct memory vector = Vector.vectorWithAngle(angle, radius);
      points[i] = Path.roundedCorner(vector.add(center));
      points[i + 1] = Path.sharpCorner(vector.mul(length).div(100).rotate(Vector.PI2 / int(count) / 2).add(center));
    }
    path = points.closedPath();
  }

  function generateSVG(uint256 _assetId) internal pure returns (string memory) {
    string memory svgPart = generateSVGPart(_assetId);
    return
      string(
        abi.encodePacked(
          SVGHeader,
          svgPart,
          '</g>\n'
          '</svg>\n'
        )
      );
  }
  
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    bytes memory image = bytes(generateSVG(_tokenId));

    return
      string(
        abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name":"',
                tokenName(_tokenId),
                '","description":"',
                description,
                '","attributes":[],"image":"data:image/svg+xml;base64,',
                Base64.encode(image),
                '"}'
              )
            )
          )
        )
      );
  }

  function generateProps(uint256 _assetId) public pure returns (Randomizer.Seed memory seed, Props memory props) {
    seed = Randomizer.Seed(_assetId, 0);
    (seed, props.count) = seed.randomize(30, 50); // +/- 50%
    (seed, props.length) = seed.randomize(40, 50); // +/- 50%
  }
 function generateSVGPart(uint256 _assetId) public pure returns (string memory svgPart) {
    Props memory props;
    (, props) = generateProps(_assetId);
    bytes memory path = generatePath(props);
    string memory tag = "1";
    svgPart = string(SVG.path(path).id(tag).svg());
  }

}

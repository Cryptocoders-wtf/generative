// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import '../packages/ERC721P2P/ERC721AP2P.sol';
import { Base64 } from 'base64-sol/base64.sol';

import '../packages/graphics/SVG.sol';

contract SimpleSVGToken is ERC721AP2P {
  using Strings for uint256;
  using Strings for uint16;
  using SVG for SVG.Element;

  uint public nextTokenId;
  
  // To be specified by the concrete contract
  string public description;
  uint public mintPrice;
  uint public mintLimit;

  constructor(
    string memory _title,
    string memory _shortTitle
  ) ERC721A(_title, _shortTitle) {
    description = 'SimpleSVGToken';
    mintLimit = 1e50;
    
  }

  function tokenName(uint256 _tokenId) internal pure returns (string memory) {
    return string(abi.encodePacked('Simple SVG Token ', _tokenId.toString()));
  }

  function mint() public payable virtual returns (uint256 tokenId) {
    require(nextTokenId < mintLimit, 'Sold out');
    _safeMint(msg.sender, 1);

    return nextTokenId++;
  }

  function totalSupply() public view override returns (uint256) {
    return nextTokenId;
  }
  // for graphics

  // Implement SVG here
  // https://github.com/Cryptocoders-wtf/generative/tree/main/contract/contracts/packages/graphicss#basic-concept
  function generateSVGPart(uint256 _tokenId) public pure returns (string memory svgPart) {
     SVG.Element memory path = SVG.rect(256, 256, 512, 512)
         .fill("yellow")
         .stroke("blue", 10)
         .transform("rotate(30 512 512)");
         
     svgPart = string(path.svg());
  }

  string constant SVGHeader =
    '<svg viewBox="0 0 1024 1024'
    '"  xmlns="http://www.w3.org/2000/svg">\n'
    '<g>\n';

  function debugGenerateSVG(uint256 _tokenId) external pure returns (string memory) {
    string memory svgPart = generateSVGPart(_tokenId);
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
      string memory svgPart = generateSVGPart(_tokenId);
      bytes memory image = abi.encodePacked(
                                            SVGHeader,
                                            svgPart,
                                            '</g>\n'
                                            '</svg>\n'
                                            );


      return string(
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


}

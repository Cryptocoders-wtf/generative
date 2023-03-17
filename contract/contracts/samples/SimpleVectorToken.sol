// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import '../packages/ERC721P2P/ERC721AP2P.sol';
import { Base64 } from 'base64-sol/base64.sol';

import '../packages/graphics/SVG.sol';

contract SimpleVectorToken is ERC721AP2P {
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
    description = 'SimpleVectorToken';
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
  // https://github.com/Cryptocoders-wtf/generative/tree/main/contract/contracts/packages/graphicss#vector-data-import

  // In generative/contract/tools directory, run 
  //   npx ts-node ./src/sample.ts
  // Then you can get enerated vector data from svg path data.
  bytes constant bitcoin = "\x4d\x70\xe1\xb7\x06\x63\x0a\x45\xbc\xd6\x44\x97\x90\x44\x7f\x6c\x50\x17\xa4\x44\xc8\xf2\x44\xea\x5a\x05\x63\xf1\x44\xfc\xe2\x44\xf9\xd3\x44\xf5\x6c\x50\x17\xa6\x44\xc8\xf2\x44\xe9\x5c\x05\x63\xf4\x44\xfd\xe8\x44\xfa\xdc\x44\xf8\x6c\x50\x00\x00\x45\xb3\xed\x44\xf1\x3c\x05\x63\x00\x55\x00\x2a\x55\x0a\x29\x55\x0a\x17\x55\x06\x1b\x55\x15\x1a\x55\x21\x6c\x40\xe6\x69\x05\x63\x02\x55\x00\x04\x55\x01\x06\x55\x02\xfe\x54\x00\xfc\x44\xff\xfa\x44\xff\x6c\x40\xdb\x93\x05\x63\xfd\x54\x07\xf6\x54\x11\xe6\x54\x0d\x01\x55\x01\xd7\x44\xf6\xd7\x44\xf6\x6c\x40\xe4\x40\x55\x49\x12\x05\x63\x0e\x55\x03\x1b\x55\x07\x28\x55\x0a\x6c\x40\xe9\x5d\x55\x38\x0e\x55\x17\xa4\x04\x63\x0f\x55\x04\x1e\x55\x08\x2d\x55\x0c\x6c\x40\xe9\x5c\x55\x38\x0e\x55\x17\xa3\x04\x63\x60\x55\x12\xa8\x55\x0b\xc6\x45\xb4\x18\x45\xba\xff\x44\x92\xcc\x44\x78\x25\x45\xf8\x40\x45\xdf\x48\x45\xae\x6c\x50\x00\x00\x05\x7a\x6d\x40\x80\xb4\x05\x63\xef\x54\x46\x79\x54\x20\x53\x54\x17\x6c\x50\x1f\x84\x04\x63\x26\x55\x09\xa0\x55\x1c\x8e\x55\x65\x7a\x00\x6d\x11\x45\x4b\x63\x40\xf0\x3f\x45\x8f\x1f\x45\x6f\x17\x05\x6c\x1c\x45\x90\x63\x50\x20\x08\x55\x86\x17\x55\x75\x59\x05\x6c\x00\x55\x00\x7a\x00";
  function generateSVGPart(uint256 _tokenId) public pure returns (string memory svgPart) {
      SVG.Element memory path = SVG.path(Path.decode(bitcoin)).fill("#F7931A");
      
     svgPart = string(path.svg());
  }

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

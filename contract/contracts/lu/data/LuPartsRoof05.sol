pragma solidity ^0.8.6;

import "./IParts.sol";

contract LuPartsRoof05 is IParts {

      function svgData() external pure override returns(uint16 sizes, bytes[] memory paths, string[] memory fill, uint8[] memory stroke) {
          sizes = 7;
          paths = new bytes[](7);
          fill = new string[](7);
          stroke = new uint8[](7);

          paths[0] = "\x4d\x80\x1e\x01\x05\x53\x12\x75\x4a\x01\x75\x5c\xb5\x75\xf3\xde\x75\xde\x63\x50\x58\xd1\x64\x0a\x41\x64\xb5\xb4\x53\xb4\x6b\x64\x53\xc7\x63\x6d\xcd\x03\x43\x00\x59\x5e\x4b\x48\xf3\x1e\x58\x01\x5a\x00";
          paths[1] = "\x4d\x50\xb7\xe2\x06\x63\xd1\x54\x22\x71\x54\x67\x51\x54\x7f\x10\x55\x1e\x2f\x55\x1e\x5b\x55\x2f\x07\x55\x03\x3a\x55\x1c\x45\x55\x21\x22\x55\x1d\x16\x55\x12\x3f\x55\x25\x1e\x45\xe8\x74\x45\xb1\xad\x45\x7e\x43\x60\x51\x28\x67\x00\x06\x57\xb7\xe2\x06\x5a";
          paths[2] = "\x4d\x60\x36\x84\x56\xf1\xb9\x06\x6c\xe0\x54\x17\x63\x50\x44\x2e\x55\x8d\x51\x55\xd1\x7a\x05\x6c\x60\x45\xad\x43\x60\xc1\xcb\x66\x80\x9f\x66\x36\x84\x06\x5a";
          paths[3] = "\x4d\x60\xaa\x2c\x66\x46\x78\x06\x63\x46\x55\x22\x88\x55\x46\xc9\x55\x73\x20\x45\xe4\x3c\x45\xcc\x4e\x45\xbd\x43\x70\x25\x7b\x66\xe9\x55\x66\xaa\x2c\x06\x5a";
          paths[4] = "\x4d\x70\x29\xe3\x05\x63\xfd\x44\xfd\xf6\x44\xfb\xf0\x44\xf6\x4c\x60\xbb\x20\x06\x63\x3c\x55\x27\x76\x55\x51\xb0\x55\x7d\x6c\x50\x06\xfc\x04\x63\x08\x45\xfc\x32\x45\xd9\x66\x45\xae\x43\x70\x9c\x27\x76\x66\x05\x76\x29\xe3\x05\x5a";
          paths[5] = "\x4d\x70\x89\x84\x75\x2b\xcb\x05\x63\x3a\x55\x32\x7e\x55\x4a\xbf\x55\x6b\x6c\x50\x57\xb7\x04\x43\x06\x58\xc4\xca\x57\x9d\x89\x57\x84\x5a\x00";
          paths[6] = "\x4d\x80\x9d\x3d\x05\x43\x8a\x58\x2c\x31\x58\x0d\x25\x58\x0f\x73\x40\xd9\x27\x45\xd9\x27\x45\xda\x14\x45\xa1\x3f\x05\x41\x59\x77\x59\x00\x55\x00\x01\x75\xf8\xa9\x05\x63\x1f\x55\x15\x40\x55\x2e\x59\x55\x36\x3a\x45\xb8\x6a\x45\xa5\x7d\x45\x8d\x43\x80\xdb\x5c\x85\xb0\x4d\x85\x9d\x3d\x05\x5a";
          fill[0] = "#504650";
          fill[1] = "#ff81ba";
          fill[2] = "#f7931e";
          fill[3] = "#9d6cd8";
          fill[4] = "#de6b96";
          fill[5] = "#9cd41e";
          fill[6] = "#29d3c3";
          stroke[0] = 0;
          stroke[1] = 0;
          stroke[2] = 0;
          stroke[3] = 0;
          stroke[4] = 0;
          stroke[5] = 0;
          stroke[6] = 0;
      }
}
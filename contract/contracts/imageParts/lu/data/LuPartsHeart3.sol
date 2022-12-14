pragma solidity ^0.8.6;

import '../../interfaces/IParts.sol';

contract LuPartsHeart3 is IParts {
  function svgData(
    uint8 index
  ) external pure override returns (uint16 sizes, bytes[] memory paths, string[] memory fill, uint8[] memory stroke) {
    sizes = 10;
    paths = new bytes[](10);
    fill = new string[](10);
    stroke = new uint8[](10);

    paths[
      0
    ] = '\x4d\x60\x5d\x5e\x07\x63\xf7\x44\xfd\xf3\x44\xee\xef\x44\xeb\xfa\x44\xf9\xea\x44\xe1\xe8\x44\xd8\xf9\x44\xec\xec\x44\xdf\xe0\x44\xcc\x73\x40\xf8\xe3\x44\xed\xd0\x04\x61\x05\x55\x05\x00\x55\x00\x01\x55\x01\xf9\x04\x63\x13\x45\xff\x0f\x55\x25\x1b\x55\x31\x14\x55\x1a\x1c\x55\x2d\x2a\x55\x49\x43\x60\x4b\x3c\x67\x6e\x5b\x67\x5d\x5e\x07\x5a';
    paths[
      1
    ] = '\x4d\x60\x08\xa2\x05\x61\x60\x55\x60\x00\x55\x00\x00\x45\xd5\x0b\x05\x43\xc6\x55\xb5\xad\x55\xbf\xa2\x55\xd6\x63\x40\xfc\x0b\x45\xfe\x17\x45\xfe\x24\x05\x73\x00\x55\x16\x04\x55\x23\x63\x40\xe8\xdd\x44\xb1\xdd\x44\x8b\xe7\x44\xf6\x04\x45\xee\x0d\x45\xe7\x15\x05\x43\xfd\x64\x2a\xfc\x64\x42\x06\x65\x5d\x63\x50\x06\x18\x55\x15\x31\x55\x28\x3f\x55\x09\x06\x55\x14\x07\x55\x20\x0c\x05\x73\x13\x55\x0c\x1e\x55\x0f\x17\x55\x01\x22\x55\x03\x16\x55\x07\x21\x55\x08\x61\x60\xcd\xcd\x56\x00\x00\x55\x00\x62\x55\x07\x63\x50\x01\xf7\x54\x07\xee\x54\x0a\xe1\x04\x73\x04\x45\xea\x08\x45\xdf\x63\x50\x09\xec\x54\x12\xd6\x54\x19\xc0\x04\x61\xee\x55\xee\x00\x55\x00\x00\x55\x0b\xbd\x04\x63\x0c\x45\xcf\xf8\x44\x9d\xc2\x44\x9c\x5a\x00';
    paths[
      2
    ] = '\x4d\x60\x08\xb0\x05\x63\x2e\x55\x00\x3a\x55\x2d\x30\x55\x54\x61\x50\xed\xed\x55\x00\x00\x55\x01\xf5\x54\x41\x63\x40\xf9\x16\x45\xf0\x2a\x45\xe7\x3f\x45\xfb\x13\x45\xf9\x25\x45\xf1\x36\x45\xe3\x02\x45\xc7\xfd\x44\xab\xf9\x44\xf5\xff\x44\xeb\xfa\x44\xe0\xf8\x04\x73\xe9\x44\xff\xdf\x44\xfd\xed\x44\xf5\xe3\x44\xf1\xea\x44\xfa\xe3\x44\xf5\x63\x40\xea\xf0\x44\xd8\xc8\x44\xd9\xab\x54\x03\xf4\x54\x0b\xee\x54\x13\xe8\x04\x73\x0e\x45\xf1\x15\x45\xee\x63\x50\x19\xfa\x54\x3b\xf9\x54\x53\x05\x55\x0f\x05\x55\x12\x1b\x55\x22\x14\x05\x73\x01\x45\xe5\x04\x45\xd8\xfd\x44\xe3\x00\x45\xd9\x63\x50\x09\xed\x54\x20\xe6\x54\x33\xdf\x04\x61\x52\x55\x52\x00\x55\x00\x01\x55\x26\xf6\x04';
    paths[
      3
    ] = '\x4d\x80\x01\x2b\x07\x63\xed\x54\x10\xea\x54\x0c\xd6\x54\x1c\x73\x40\xef\x13\x45\xdc\x23\x45\xed\x11\x45\xda\x21\x05';
    paths[
      4
    ] = '\x4d\x70\x8d\x8f\x07\x63\xec\x44\xfc\x1c\x45\xde\x23\x45\xd6\x13\x45\xf0\x11\x45\xee\x24\x45\xdd\x73\x50\x17\xf4\x54\x2a\xe4\x04\x63\x05\x45\xfc\x0c\x55\x04\x07\x55\x08\xec\x54\x10\xe9\x54\x0c\xd6\x54\x1c\x43\x70\xbf\x64\x77\xac\x7a\x77\x8d\x8f\x07\x5a';
    paths[
      5
    ] = '\x4d\x80\x42\x62\x06\x63\xe6\x54\x00\xd0\x54\x0b\xc1\x54\x21\xf1\x54\x10\xeb\x54\x20\xe7\x54\x36\xff\x54\x0a\x02\x55\x14\x02\x55\x1f\x73\x40\xfe\x15\x45\xff\x1f\x55\x06\x15\x55\x08\x1e\x55\x03\x17\x55\x04\x1f\x05\x63\x10\x45\xfd\x24\x45\xfb\x36\x45\xf8\x0b\x45\xff\x15\x45\xfa\x20\x45\xfa\x10\x55\x02\x21\x45\xfe\x30\x45\xfb\x73\x50\x25\xfc\x54\x35\xf6\x54\x20\xec\x54\x24\xda\x54\x00\xdd\x44\xf1\xd1\x04\x63\xec\x44\xeb\xd5\x44\xe5\xb9\x44\xf2\xf8\x54\x03\xf3\x54\x03\xea\x54\x09\x06\x45\xfa\x06\x45\xf6\x07\x45\xec\x06\x45\xe1\xf1\x44\xbb\xcf\x44\xb9\x5a\x00';
    paths[
      6
    ] = '\x4d\x80\x42\x70\x06\x68\x00\x05\x63\x10\x55\x00\x1f\x55\x13\x22\x55\x22\x61\x50\x32\x32\x55\x00\x00\x55\x01\x01\x55\x15\x63\x40\xff\x07\x55\x00\x0c\x45\xfe\x12\x05\x73\xfa\x54\x10\xfa\x54\x10\xff\x54\x03\x03\x55\x03\x0d\x45\xfe\x10\x45\xfc\x0a\x45\xfe\x10\x45\xfc\x63\x50\x0f\xfa\x54\x1f\xf3\x54\x2e\xfc\x04\x73\x19\x55\x12\x1e\x55\x1d\x63\x50\x02\x04\x55\x01\x0b\x45\xff\x11\x45\xfb\x14\x45\xe8\x1d\x45\xd3\x21\x45\xf5\x03\x45\xea\x03\x45\xde\x05\x05\x73\xee\x54\x04\xe6\x54\x05\xf3\x54\x00\xec\x54\x00\x63\x40\xf4\x00\x45\xe9\x04\x45\xdf\x06\x05\x73\xe5\x54\x03\xd7\x54\x05\x63\x50\x00\xf1\x44\xf9\xe0\x44\xf6\xd1\x44\xff\xf7\x54\x02\xec\x54\x01\xe2\x04\x73\xfd\x44\xec\xfe\x44\xe3\x63\x50\x03\xeb\x54\x0a\xdd\x54\x1a\xcc\x54\x0b\xf0\x54\x1c\xeb\x54\x30\xea\x04';
    paths[
      7
    ] = '\x4d\x70\x56\x67\x07\x63\xed\x54\x01\x23\x45\xba\x21\x45\xaa\x04\x45\xe5\x18\x45\xd1\x25\x45\xb9\x73\x50\x0f\xcd\x54\x1c\xb7\x04\x6c\x0a\x45\xea\x63\x50\x03\xfa\x54\x0c\xfe\x54\x0a\x04\x45\xee\x23\x45\xe7\x3a\x45\xda\x5f\x45\xf5\x18\x45\xef\x16\x45\xe4\x2d\x05\x73\xf0\x54\x36\xe0\x54\x4d\x43\x70\x63\x4f\x77\x61\x61\x77\x56\x67\x07\x5a';
    paths[
      8
    ] = '\x4d\x70\xcb\x00\x05\x63\xd7\x54\x05\xb8\x54\x33\xa6\x54\x55\xfb\x54\x0d\xfe\x54\x1a\xfe\x54\x26\x73\x40\xfa\x16\x45\xfc\x22\x05\x63\x0e\x55\x1e\x12\x55\x42\x21\x55\x61\x61\x60\x13\x13\x56\x00\x00\x55\x00\x22\x55\x3b\x63\x50\x07\x16\x55\x14\x3f\x55\x27\x38\x55\x5e\xdf\x64\x10\xb0\x64\x29\x55\x54\x11\xc7\x44\xdd\xa1\x44\xaf\x92\x04\x53\x58\x58\x6c\x3c\x58\x8e\x63\x50\x0e\xd2\x44\xf0\x9b\x44\xcb\x7e\x44\xef\xf8\x44\xd7\xf6\x44\xc4\xf4\x04\x5a';
    paths[
      9
    ] = '\x4d\x70\xcb\x0e\x05\x63\x0f\x55\x02\x27\x55\x04\x35\x55\x0a\x19\x55\x15\x30\x55\x37\x31\x55\x59\x04\x55\x12\xf2\x54\x27\x0b\x55\x2b\x0d\x45\xff\x12\x45\xef\x1c\x45\xe8\x16\x45\xea\x33\x45\xd8\x4f\x45\xe0\x28\x55\x0b\x3c\x55\x1f\x4b\x55\x39\x0b\x55\x51\xa2\x54\x81\x63\x54\x99\xd4\x54\x10\xa6\x54\x1e\x7a\x54\x2c\xf4\x44\xf2\xf1\x44\xe1\xe9\x44\xd0\xf8\x44\xf3\xed\x44\xe8\xe8\x44\xda\xeb\x44\xdd\xe8\x44\xb3\xd7\x44\x8f\x03\x45\xec\x03\x45\xd3\x06\x45\xbf\x10\x45\xe3\x2c\x45\xba\x4d\x45\xb4';
    fill[0] = '#504650';
    fill[1] = '#504650';
    fill[2] = '#9d6cd8';
    fill[3] = '#ff8ca1';
    fill[4] = '#504650';
    fill[5] = '#504650';
    fill[6] = '#ff62a1';
    fill[7] = '#504650';
    fill[8] = '#504650';
    fill[9] = '#ff7981';
    stroke[0] = 0;
    stroke[1] = 0;
    stroke[2] = 0;
    stroke[3] = 0;
    stroke[4] = 0;
    stroke[5] = 0;
    stroke[6] = 0;
    stroke[7] = 0;
    stroke[8] = 0;
    stroke[9] = 0;
  }
}

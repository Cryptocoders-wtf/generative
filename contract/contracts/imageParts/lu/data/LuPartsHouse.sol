pragma solidity ^0.8.6;

import '../../interfaces/IParts.sol';

contract LuPartsHouse is IParts {
  function svgData(
    uint8 index
  ) external pure override returns (uint16 sizes, bytes[] memory paths, string[] memory fill, uint8[] memory stroke) {
    sizes = 5;
    paths = new bytes[](5);
    fill = new string[](5);
    stroke = new uint8[](5);

    paths[
      0
    ] = '\x4d\x80\x6b\x13\x06\x63\xe7\x44\xf7\xc8\x44\xd1\xb1\x44\xc3\xf5\x44\xf6\xc5\x44\xd4\xbc\x44\xc9\x43\x70\xa3\x7f\x75\x4f\x34\x75\x46\x2a\x05\x63\xfb\x44\xfd\xe4\x44\xed\xd1\x44\xe9\x43\x60\xe3\x01\x65\xe7\xff\x64\xd1\x00\x05\x53\xb9\x56\x0e\xaa\x56\x18\x63\x40\xe3\x17\x45\xc0\x2d\x45\xa3\x43\x45\xf9\x0a\x45\xdc\x1f\x45\xd1\x24\x45\xee\x0e\x45\xf1\x14\x45\xdb\x1b\x45\xef\x10\x45\xc1\x3a\x45\xa3\x4a\x45\xfd\x01\x45\xca\x2e\x45\xc0\x33\x05\x43\x3d\x65\x23\x2a\x65\x3f\x0b\x65\x4a\x63\x40\xed\x07\x45\xf8\x1f\x45\xff\x2b\x55\x0c\x13\x55\x04\x29\x55\x0d\x3d\x55\x07\x0f\x55\x08\x1e\x55\x09\x2e\x55\x09\x29\x55\x0c\x53\x55\x10\x7d\x45\xfd\x12\x55\x05\x22\x55\x09\x34\x55\x02\x24\x55\x14\x45\x55\x14\x69\x55\x01\x0b\x55\x0c\x4a\x55\x10\x60\x55\x16\x16\x55\x0d\x31\x55\x0f\x44\x45\xff\x07\x45\xfa\x2a\x45\xfa\x2a\x05\x61\x1a\x55\x1a\x00\x55\x00\x00\x45\xe7\x01\x05\x63\xf6\x54\x0c\x01\x55\x21\x03\x55\x30\x21\x55\x10\x53\x55\x03\x78\x55\x05\x3c\x55\x04\x56\x45\xf8\x94\x45\xfa\x4a\x55\x02\x6e\x55\x08\xaa\x45\xff\x24\x45\xfb\x5c\x55\x08\x8c\x55\x04\x28\x45\xfd\xd9\x55\x09\xfd\x45\xf5\x11\x45\xf6\x0b\x45\xe0\xf5\x44\xd0\x61\x50\x18\x18\x55\x00\x00\x55\x00\xf7\x44\xfc\x63\x40\xfe\xe4\x54\x0b\xc7\x54\x09\xa9\x54\x00\xbb\x54\x11\x7e\x54\x12\x36\x44\xfb\xe8\x54\x08\xcb\x54\x09\xb3\x54\x06\xdc\x54\x0b\xd4\x54\x0f\xbb\x54\x0c\xaf\x54\x0e\xb0\x54\x15\x67\x04\x43\xc9\x68\x66\xb0\x68\x50\x6b\x68\x13\x5a\x00';
    paths[
      1
    ] = '\x4d\x60\x28\x29\x06\x63\x2d\x45\xe1\x31\x45\xdd\x5c\x45\xba\x53\x60\xde\x90\x75\x10\x63\x05\x63\x0b\x45\xf8\x12\x45\xf3\x20\x55\x01\x1e\x55\x17\x3b\x55\x26\x59\x55\x3c\x15\x55\x10\x52\x55\x38\x8e\x55\x67\x18\x55\x12\x49\x55\x33\x52\x55\x3a\x20\x55\x18\x46\x55\x38\x48\x55\x46\x05\x55\x23\x00\x55\x00\x00\x55\x21\x00\x55\x2c\xf8\x54\x2c\xf1\x54\x57\x02\x55\x1c\xf0\x54\x61\xeb\x54\x7d\xff\x54\x18\x01\x55\x53\xfa\x54\x6b\xf5\x54\x5b\xf4\x54\x7d\xe9\x54\xda\xfe\x54\x13\xf1\x54\x08\xe4\x54\x08\x73\x40\xc1\xfe\x44\xb2\x04\x05\x63\xf9\x54\x00\xd2\x44\xfe\xc4\x44\xfd\xd4\x44\xfe\x2d\x54\x0a\x0d\x54\x01\xfc\x44\xfa\x1b\x54\x06\x04\x54\x02\xfa\x44\xfe\xe5\x44\xfe\xdf\x44\xfe\xf1\x44\xf9\xf8\x44\xc5\xf6\x44\xb5\xf5\x44\xce\xfd\x44\x9b\xf2\x44\x69\xff\x44\xf6\xf4\x44\xb7\xf8\x44\xa1\xff\x44\xde\xf6\x44\xbc\xf2\x44\x9a\xfb\x44\xeb\x03\x45\xd6\xfe\x44\xc2\xfc\x44\xf1\x01\x45\xd0\x02\x45\xbf\x00\x55\x00\x2f\x45\xdb\x55\x45\xc0\x43\x50\xfc\x52\x66\x10\x38\x66\x28\x29\x06\x5a';
    paths[
      2
    ] = '\x4d\x50\x14\x74\x06\x63\x0a\x55\x02\x6d\x55\x36\x6e\x55\x3e\x01\x55\x0e\xfb\x54\x23\xff\x54\x30\x05\x55\x15\xfd\x54\x2b\x02\x55\x40\x04\x55\x26\x10\x55\x4c\x0e\x55\x71\x00\x55\x12\x0c\x55\x22\x09\x55\x34\x00\x55\x27\x07\x55\x4d\x08\x55\x73\x01\x55\x11\xfd\x54\x22\x03\x55\x32\x08\x55\x15\x00\x55\x2b\x05\x55\x40\x01\x55\x05\xfd\x54\x11\xfc\x54\x17\x00\x55\x02\x06\x55\x08\xfe\x54\x08\xcc\x54\x00\xda\x54\x05\xd5\x44\xf7\xfc\x44\xf7\xf9\x44\xcc\xfc\x44\xc2\x03\x45\xef\xfa\x44\xde\xf3\x44\xce\xf9\x44\xec\x00\x45\xd6\xf5\x44\xc3\xfc\x44\xf4\xf8\x44\xe8\xfc\x44\xdc\x61\x50\xf9\xf9\x55\x00\x00\x55\x01\xf8\x44\xd9\x63\x40\xf7\xe9\x44\xf5\xd1\x44\xf0\xb9\x44\xf3\xe4\x44\xff\xc5\x44\xf4\xa8\x44\xfb\xd8\x44\xfb\xaf\x44\xef\x89\x04\x43\x19\x65\xa2\x20\x65\x89\x14\x65\x74\x5a\x00';
    paths[
      3
    ] = '\x4d\x80\x99\x42\x06\x63\x26\x55\x28\x25\x55\x33\x0d\x55\x1e\xea\x44\xf9\xa4\x44\xbb\x8c\x44\xad\xf3\x44\xf8\x7a\x44\x96\x57\x44\x7d\xe1\x44\xeb\xd5\x44\xdd\xb5\x44\xca\xfa\x54\x00\xe2\x44\xe8\xe6\x44\xe6\x18\x45\xee\x0c\x45\xf7\x1b\x45\xfe\x26\x55\x1c\x72\x55\x53\x97\x55\x6f\x26\x55\x16\x3a\x55\x32\x5d\x55\x4d\x43\x80\x41\xff\x85\x7a\x37\x86\x99\x42\x06\x5a';
    paths[
      4
    ] = '\x4d\x50\x68\xd1\x08\x63\xf4\x44\xfc\xf0\x54\x01\xed\x54\x02\xf6\x54\x08\x01\x55\x15\x03\x55\x20\x21\x55\x0c\x4c\x55\x00\x71\x55\x02\x3c\x55\x02\x56\x45\xfb\x94\x45\xfc\x4a\x55\x01\x6e\x55\x05\xaa\x45\xff\x24\x45\xfc\x5c\x55\x06\x8c\x55\x03\x28\x45\xfe\xd3\x55\x08\xf6\x45\xfb\x00\x55\x00\x12\x45\xf2\xfc\x44\xe6\xf0\x44\xf8\xa1\x54\x02\x8e\x54\x03\xc2\x54\x02\x8a\x44\xfb\x4d\x44\xff\x73\x40\x84\x01\x45\x47\xff\x04\x63\xda\x44\xff\xc0\x54\x08\x9a\x54\x02\xdf\x44\xfb\xb7\x44\xfd\x95\x44\xfc\xc6\x44\xfe\xf1\x44\xfe\xcc\x44\xff\x43\x50\x85\xd0\x58\x78\xd3\x58\x68\xd1\x08\x5a';
    fill[0] = '#504650';
    fill[1] = '#fefefe';
    fill[2] = '#de6b96';
    fill[3] = '#af5366';
    fill[4] = '#ccd7c7';
    stroke[0] = 0;
    stroke[1] = 0;
    stroke[2] = 0;
    stroke[3] = 0;
    stroke[4] = 0;
  }
}

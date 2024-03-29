pragma solidity ^0.8.6;

import "../../interfaces/IParts.sol";

contract LuPartsHeartA is IParts {

      function svgData(uint8 index) external pure override returns(uint16 sizes, bytes[] memory paths, string[] memory fill, uint8[] memory stroke) {
          sizes = 18;
          paths = new bytes[](18);
          fill = new string[](18);
          stroke = new uint8[](18);

          paths[0] = "\x4d\x80\x4e\x00\x05\x63\xf4\x54\x00\xcb\x54\x02\xc3\x54\x03\xf2\x54\x00\xce\x54\x01\xbf\x54\x0e\xf6\x54\x0a\xca\x54\x18\xa2\x54\x38\xe3\x54\x18\x9f\x54\x4f\x90\x54\x53\x43\x60\x93\x6d\x55\xe3\x18\x55\x61\x66\x55\x02\x9e\x45\xd8\x27\x56\x31\x76\x06\x63\x11\x55\x0b\x39\x55\x33\x42\x55\x40\x32\x55\x2a\x6b\x55\x46\x9e\x55\x6c\x30\x55\x17\x50\x55\x3e\x83\x55\x53\x2c\x55\x09\x50\x55\x33\x7c\x55\x33\x07\x45\xff\x2e\x45\xe5\x2e\x45\xe5\x14\x45\xf4\x41\x45\xd4\x4b\x45\xc9\x12\x45\xee\x30\x45\xf2\x43\x45\xde\x13\x45\xe7\x3d\x45\xe9\x50\x45\xcd\x09\x45\xf1\x22\x45\xf2\x2a\x45\xde\x14\x45\xeb\x5f\x45\x9e\x5b\x45\x9d\x08\x45\xf2\x47\x45\x9d\x4c\x45\x8d\x43\x90\x25\x6c\x85\xe4\x16\x85\x4e\x00\x05\x5a\x4d\x60\xfe\x63\x07\x63\xef\x44\xfc\xa3\x44\xc5\x92\x44\xb5\x00\x55\x00\xd3\x44\xda\xc1\x44\xcb\xf1\x44\xf4\xe2\x44\xe8\xcc\x44\xd9\xf9\x44\xfa\xed\x44\xf0\xe1\x44\xe5\xe6\x44\xe9\xd9\x44\xdd\xd1\x44\xd9\xcc\x44\xdc\xbe\x44\x9e\xca\x44\x73\x73\x50\x2f\xbf\x54\x5f\xbf\x04\x61\x9b\x55\x9b\x00\x55\x00\x01\x55\x15\x01\x05\x68\x01\x05\x61\x60\x55\x60\x00\x55\x00\x01\x55\x13\x02\x55\x8a\x8a\x55\x00\x00\x55\x00\x18\x55\x02\x43\x55\x43\x00\x55\x00\x00\x55\x0b\xff\x04\x68\x02\x05\x63\x10\x55\x00\x2b\x55\x0c\x46\x55\x18\x73\x50\x2c\x0e\x55\x37\x12\x05\x63\x01\x55\x00\x17\x55\x0b\x1d\x55\x0f\x0e\x55\x09\x15\x55\x10\x1c\x55\x0e\x61\x50\x72\x72\x55\x00\x00\x55\x00\x17\x45\xf7\x63\x50\x09\xfb\x54\x27\xea\x54\x4b\xd2\x54\x0e\xf7\x54\x1b\xee\x54\x23\xe9\x04\x68\x01\x05\x6c\x01\x45\xff\x63\x50\x07\xfa\x54\x20\xf3\x54\x33\xee\x54\x19\xf9\x54\x2a\xf4\x54\x33\xed\x04\x68\x01\x05\x63\x14\x45\xfd\x2b\x45\xf9\x40\x45\xf9\x1b\x55\x00\x2f\x55\x06\x3b\x55\x13\x12\x55\x14\x0f\x55\x25\x0e\x55\x30\x61\x50\x26\x26\x55\x00\x00\x55\x00\x00\x55\x0b\x63\x40\xf9\x80\x45\x95\xd1\x45\x2c\x1f\x46\xdf\x18\x45\xc3\x32\x45\xa7\x4b\x55\x00\x00\x45\xe0\x18\x45\xce\x22\x05\x43\x0e\x77\x58\x03\x77\x60\xfe\x76\x63\x5a\x00";
          paths[1] = "\x4d\x80\xf6\xac\x05\x63\x00\x45\x99\xc0\x44\x75\x65\x44\x63\xed\x44\xf6\xd8\x44\xfe\xc5\x54\x01\xf6\x44\xfe\xcd\x54\x05\xb2\x54\x0f\xee\x54\x11\xc0\x54\x20\x8c\x54\x4b\xed\x54\x13\xab\x54\x4b\xa3\x54\x45\x43\x60\xb8\x8b\x65\x35\x53\x65\x16\x52\x05\x53\xaa\x55\x48\x67\x55\x70\x43\x50\x4d\x87\x55\x28\x9d\x55\x1d\xc1\x05\x63\xe2\x54\x32\xec\x54\x86\x1b\x55\xab\x0e\x55\x09\x3b\x55\x33\x43\x55\x40\x31\x55\x29\x6b\x55\x46\x9d\x55\x6b\x2f\x55\x16\x4e\x55\x3b\x7e\x55\x51\x3c\x55\x16\x67\x55\x40\x7c\x55\x31\x07\x45\xf9\x1d\x45\xea\x21\x45\xe8\x73\x50\x43\xd8\x54\x4d\xcd\x04\x63\x12\x45\xec\x30\x45\xf0\x43\x45\xde\x13\x45\xe6\x3c\x45\xe7\x4f\x45\xcf\x08\x45\xef\x22\x45\xf0\x2a\x45\xde\x05\x45\xf8\x55\x45\xac\x5b\x45\x9e\x12\x45\xe3\x34\x45\xba\x46\x45\x9d\x43\x80\xe2\xfd\x85\xf9\xb8\x85\xf6\xac\x05\x5a\x4d\x80\x7d\xc8\x05\x63\xf8\x54\xaf\x46\x64\x08\xcd\x63\x71\xf0\x54\x15\xcf\x54\x23\xb9\x54\x31\xf5\x54\x0b\x8f\x44\xbd\x83\x44\xb3\xca\x44\xdf\xc2\x44\xcb\x8f\x44\xa8\xed\x44\xf1\xbe\x44\xc3\xb4\x44\xbf\x9c\x44\xbc\xaa\x44\x0a\x46\x45\x1e\x12\x55\x00\x20\x55\x07\x34\x55\x04\x1f\x45\xfc\x75\x55\x23\x88\x55\x27\x2b\x55\x18\x30\x55\x20\x3e\x55\x19\x53\x70\x62\xad\x75\x7b\x9e\x05\x63\x12\x45\xf2\x5d\x45\xe5\x69\x45\xd9\x2c\x45\xf9\x69\x45\xed\x89\x55\x0f\x53\x80\x7a\xc3\x85\x7d\xc8\x05\x5a";
          paths[2] = "\x4d\x60\xb2\xc4\x05\x63\xe5\x44\xf4\xc3\x44\xee\xb1\x44\xe6\xfb\x44\xfe\xf8\x44\xd5\xf1\x44\xc7\x00\x45\xfa\xf6\x44\xf3\x01\x45\xf5\x61\x60\x26\x26\x56\x00\x00\x55\x01\x36\x55\x11\x63\x50\x11\x07\x55\x2b\x15\x55\x35\x1b\x55\x00\x00\x45\xff\x01\x45\xfa\x12\x05\x43\xb5\x56\xb1\xb3\x56\xb8\xb2\x56\xc4\x5a\x00";
          paths[3] = "\x4d\x50\x67\x70\x55\xca\xa5\x05\x6c\x24\x45\xf9\x43\x50\xe5\x8a\x55\xae\x56\x55\xae\x56\x55\x86\x59\x55\x67\x70\x55\x67\x70\x05\x5a";
          paths[4] = "\x4d\x50\x0d\xf6\x05\x63\xfe\x44\xf9\x03\x45\xe3\x0b\x45\xe3\x24\x55\x0b\x4b\x55\x18\x6e\x55\x26\x6c\x50\x01\x0a\x05\x63\x0a\x55\x41\x0b\x55\x30\xd8\x54\x41\xea\x54\x08\xc8\x54\x13\xc4\x54\x0d\x43\x50\x02\x23\x56\x10\x02\x56\x0d\xf6\x05\x5a";
          paths[5] = "\x4d\x60\x3b\xe1\x06\x63\xf5\x54\x0e\xdf\x54\x23\xcf\x54\x2a\xfd\x54\x02\xee\x44\xf6\xe7\x44\xf2\xf3\x44\xf7\xe3\x44\xf1\xd8\x44\xe6\xee\x44\xf1\xd8\x44\xea\xc8\x44\xdb\xfe\x44\xfe\x44\x45\xd7\x52\x45\xde\x11\x55\x08\x2e\x55\x20\x33\x55\x25\x43\x60\x23\xcc\x66\x2f\xd6\x66\x3b\xe1\x06\x5a";
          paths[6] = "\x4d\x60\xe5\x90\x07\x63\xf7\x44\xf8\xec\x44\xf6\xe2\x44\xf1\xfc\x44\xfe\xf7\x44\xfc\xf4\x44\xf8\x03\x45\xf8\x12\x45\xe2\x1a\x45\xde\x02\x45\xff\x15\x55\x0a\x1d\x55\x0d\x73\x40\xfe\x11\x45\xfc\x17\x05\x53\xec\x76\x92\xe5\x76\x90\x5a\x00";
          paths[7] = "\x4d\x70\xb8\xe3\x06\x63\x05\x55\x07\x26\x55\x36\x1e\x55\x3a\xf2\x54\x02\xeb\x54\x1f\xe0\x54\x0f\x43\x70\x90\xfa\x76\x92\xf8\x76\xb8\xe3\x06\x5a";
          paths[8] = "\x4d\x80\x3d\xd9\x06\x63\xfb\x54\x08\xf3\x54\x0f\xea\x54\x12\x73\x40\xe3\x21\x45\xcb\x26\x05\x63\xf0\x54\x03\xe9\x44\xdf\xdf\x44\xd6\xfc\x44\xfc\xf7\x44\xef\xf7\x44\xef\x03\x45\xfa\x1a\x45\xec\x27\x45\xe1\x09\x45\xf9\x10\x45\xf2\x10\x45\xf2\x43\x80\x11\xb4\x86\x2e\xca\x86\x3d\xd9\x06\x5a";
          paths[9] = "\x4d\x80\x7c\xd6\x85\xf2\xca\x05\x63\x02\x55\x08\xf3\x54\x36\xef\x54\x40\x73\x40\xf2\x16\x45\xf2\x16\x05\x6c\xa1\x44\xe5\x43\x80\x79\xfa\x85\x7c\xd6\x85\x7c\xd6\x05\x5a";
          paths[10] = "\x4d\x80\x48\x62\x05\x63\x01\x45\xef\x13\x45\xb1\x1b\x45\xb0\x0e\x55\x02\x1b\x55\x02\x27\x55\x09\x14\x55\x02\x22\x55\x10\x33\x55\x17\x06\x55\x02\x26\x55\x1f\x29\x55\x2d\x53\x80\x86\x90\x85\x79\x99\x05\x63\x00\x55\x00\xf6\x44\xeb\xf0\x44\xe8\xed\x44\xf5\xe5\x44\xf2\xda\x44\xef\x43\x80\x41\x70\x85\x47\x64\x85\x48\x62\x05\x5a";
          paths[11] = "\x4d\x80\x18\xe8\x05\x63\xea\x44\xe6\xcb\x44\xd8\xa5\x44\xd8\x73\x40\xae\x0f\x45\x8b\x27\x05\x6c\xff\x54\x00\x00\x55\x01\x63\x40\xd9\x24\x45\xcc\x30\x45\xc7\x35\x05\x6c\xff\x54\x00\xfe\x54\x02\xfd\x44\xfd\x63\x40\xf4\xf6\x44\xe1\xe6\x44\xcf\xde\x44\xdd\xe7\x44\xb0\xd8\x44\x77\xd5\x04\x6c\xfd\x54\x00\xfd\x54\x01\x63\x40\xd7\x09\x45\xb9\x1f\x45\xac\x3e\x05\x73\xf9\x54\x47\x13\x55\x69\x63\x50\x1f\x41\x55\x71\x74\x55\xad\x99\x55\x19\x0f\x55\x34\x28\x55\x34\x28\x05\x6c\x1c\x55\x0c\x63\x50\x21\xf7\x54\x5d\xc9\x54\xc7\x61\x54\x11\xef\x54\x20\xe1\x54\x2b\xd6\x54\x25\xde\x54\x39\xbc\x54\x3a\x9e\x04\x41\x44\x55\x44\x00\x55\x00\x00\x85\x18\xe8\x05\x5a\x6d\x40\x6e\xad\x05\x63\xfa\x54\x07\xec\x54\x14\xe2\x54\x1e\xcf\x54\x36\xaf\x54\x5a\x9a\x54\x5a\xff\x54\x00\xed\x44\xf8\xed\x44\xf8\x73\x40\xe8\xed\x44\xd9\xe3\x04\x63\xde\x44\xe8\xb6\x44\xca\xa6\x44\xa2\xf3\x44\xed\xf7\x44\xd6\xfe\x44\xc4\x73\x50\x16\xe2\x54\x2b\xdd\x04\x6c\x01\x55\x00\x19\x45\xfe\x61\x50\x6b\x6b\x55\x00\x00\x55\x01\x39\x55\x19\x63\x50\x0e\x07\x55\x16\x12\x55\x18\x12\x05\x73\x1c\x45\xe3\x32\x45\xd5\x63\x50\x13\xf4\x54\x1f\xf8\x54\x34\xf8\x04\x73\x24\x55\x08\x2f\x55\x17\x43\x70\xa9\x4d\x76\xa5\x75\x76\x86\x95\x06\x5a";
          paths[12] = "\x4d\x80\x10\xf0\x05\x63\xec\x44\xe8\xd0\x44\xdb\xad\x44\xdb\x73\x40\xb2\x0e\x45\x91\x25\x05\x6c\xbd\x54\x3e\x63\x40\xfd\x00\x45\xde\xe2\x44\xc6\xd7\x44\xdf\xe8\x44\xb3\xda\x44\x7c\xd6\x04\x68\xfe\x04\x6c\xfe\x54\x00\x63\x40\xdb\x08\x45\xbf\x1b\x45\xb4\x37\x05\x73\xfb\x54\x3f\x12\x55\x5e\x63\x50\x1d\x3e\x55\x6f\x6c\x55\xa9\x95\x55\x1e\x15\x55\x37\x2a\x55\x37\x2a\x05\x73\x0d\x55\x08\x0e\x55\x08\x63\x50\x25\x00\x55\x6d\xba\x54\xc3\x65\x54\x11\xef\x54\x20\xe0\x54\x2b\xd6\x04\x43\x23\x68\x41\x31\x68\x11\x10\x58\xf0\x5a\x00\x6d\x7b\x54\xaf\xea\x54\x19\x63\x40\xc5\x42\x45\xab\x61\x45\x8f\x61\x45\xff\x00\x45\xd4\xea\x44\xc8\xe1\x44\xdf\xe9\x44\xb2\xc9\x44\xa0\x9f\x44\xf1\xe8\x44\xec\xcd\x44\xf5\xb6\x04\x73\x1d\x45\xd8\x38\x45\xd1\x6c\x50\x09\xff\x04\x63\x21\x55\x02\x3c\x55\x0c\x51\x55\x1d\x61\x50\x71\x71\x55\x00\x00\x55\x01\x12\x55\x0d\x6c\x50\x11\xee\x54\x16\xef\x04\x63\x16\x45\xf3\x20\x45\xf0\x38\x45\xf0\x61\x50\x4a\x4a\x55\x00\x00\x55\x01\x3d\x55\x1e\x43\x70\xa9\x40\x76\xc1\x67\x76\x8b\xa0\x06\x5a";
          paths[13] = "\x4d\x60\x1f\xeb\x05\x6c\x65\x55\x3e\x63\x40\xf2\x04\x45\xe0\x16\x45\xde\x1e\x45\xe1\xfa\x44\x96\xfb\x44\x96\xfb\x04\x43\xec\x65\x03\x1f\x56\xeb\x1f\x56\xeb\x5a\x00";
          paths[14] = "\x4d\x70\x3e\xf4\x06\x6c\x0b\x55\x15\x63\x50\x08\xfd\x54\x27\xe2\x54\x2c\xda\x44\xfa\xf2\x44\xe9\xee\x44\xe9\xee\x04\x5a";
          paths[15] = "\x4d\x70\x8e\x24\x06\x6c\x3f\x45\xa9\x63\x50\x22\xfc\x54\x48\x24\x55\x4b\x31\x45\xe9\x13\x45\x8d\x3f\x45\x8d\x3f\x05\x43\x9d\x67\x34\x8e\x67\x24\x8e\x67\x24\x5a\x00";
          paths[16] = "\x4d\x70\x74\xda\x05\x6c\xf6\x54\x3b\x63\x50\x0f\x02\x55\x22\x0d\x55\x22\x0d\x05\x6c\x43\x45\xac\x43\x70\x9f\xc2\x75\x74\xda\x75\x74\xda\x05\x5a";
          paths[17] = "\x4d\x70\x06\xe8\x06\x63\xf9\x44\xfb\xde\x44\xe8\xd3\x44\xe1\xe4\x44\xec\xc3\x44\xd1\xb9\x44\xb7\x00\x55\x00\x00\x45\xe9\x05\x45\xe3\x0f\x45\xec\x23\x45\xef\x23\x45\xef\x12\x55\x04\x19\x55\x08\x22\x55\x0f\x73\x50\x16\x18\x55\x25\x23\x05\x6c\x02\x55\x02\x15\x45\xea\x63\x50\x09\xf7\x54\x18\xe6\x54\x25\xde\x54\x07\xfc\x54\x18\xfd\x54\x22\x02\x05\x73\x09\x55\x03\x11\x55\x0b\x03\x55\x25\xf3\x54\x36\x63\x40\xfe\x02\x45\xe7\x1f\x45\xe0\x26\x05\x5a";
          fill[0] = "#504650";
          fill[1] = "#dd57b1";
          fill[2] = "#9d6cd8";
          fill[3] = "#5eccd0";
          fill[4] = "#ff79c1";
          fill[5] = "#ffa141";
          fill[6] = "#ff79c1";
          fill[7] = "#9d6cd8";
          fill[8] = "#ff79c1";
          fill[9] = "#5eccd0";
          fill[10] = "#ffa141";
          fill[11] = "#504650";
          fill[12] = "#ff8463";
          fill[13] = "#dd57b1";
          fill[14] = "#ff79c1";
          fill[15] = "#9d6cd8";
          fill[16] = "#ff5cc1";
          fill[17] = "#5ee3eb";
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
          stroke[10] = 0;
          stroke[11] = 0;
          stroke[12] = 0;
          stroke[13] = 0;
          stroke[14] = 0;
          stroke[15] = 0;
          stroke[16] = 0;
          stroke[17] = 0;
      }
}
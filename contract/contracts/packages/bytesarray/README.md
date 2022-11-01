# BytesArray

## Usage

```
import "bytes-array.sol/BytesArray.sol";

contract YourContract {
  using BytesArray for bytes[];

  function yourFunction() {
    ...
    bytes[] memory parts = new bytes[](length);
    for (uint i=0; i<length; i++) {
      ...
      parts[i] = abi.encodePacked(...);
    }
  }
  bytes[] result =parts.packed();
  ...
}
```
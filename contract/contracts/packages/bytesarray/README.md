# BytesArray

## Usage

### Before

```
contract YourContract {
  // This is O(N^2) because of reallocations
  function yourFunction() returns (bytes memory result) {
    ...
    for (uint i = 0; i < N; i++) {
      ...
      // Reallocation
      result = abi.encodePacked(result, ...);
    }
  }
}
```
### After

```
import "bytes-array.sol/BytesArray.sol";

contract YourContract {
  // This is O(N)
  using BytesArray for bytes[];

  function yourFunction() returns (bytes memory result) {
    ...
    bytes[] memory parts = new bytes[](N);
    for (uint i = 0; i < N; i++) {
      ...
      parts[i] = abi.encodePacked(...);
    }
    result = parts.packed();
  }
}
```
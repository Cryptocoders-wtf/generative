# Trigonometry

Basic Trigonometric functions for smart contracts

## Usage

```
import "trigonometry.sol/Trigonometry.sol";

contract YourContract {
  using Trigonometry for uint;

  function YourMethod() {
    uint angle = 60; // degree
    int radias = 800; // pixel
    uint x = (angle * 0x4000 / 360).cos() * radias / 0x7fff;
    uint y = (angle * 0x4000 / 360).sin() * radias / 0x7fff;
    ...
  }
}

```
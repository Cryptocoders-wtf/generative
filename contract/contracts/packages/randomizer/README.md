# Randomizer.sol

This library was created to generate a sequence of pseudo random numbers deterministically.

## Usage
```
import "randomizer.sol/Randomizer.sol";

contract YourContract {
  using Randomizer for Randomizer.Seed;

  function YourMethod(uint seedId) {
    // Initialize the seed with a particular number, which determines the sequence.
    Randomizer.Seed memory seed = Randomizer.Seed(assetId, 0);

    // Generate a pseudo random number between 0 and 99
    uint numberA;
    (seed, numberA) = seed.random(100);

    // Randomize the number by +-33%
    uint numberB = 100;
    (seed, numberB) = seed.randomize(numberB, 33);

    ...
  }
```

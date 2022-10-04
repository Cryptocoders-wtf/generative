# Randomizer.sol

This library was created to generate a sequence of pseudo random numbers deterministically.

## Usage
```
// Initialize the seed with a number, such as assetId
Randomizer.Seed memory seed = Randomizer.Seed(assetId, 0);

// Generate a pseudo random number between 0 and 99
uint number;
(seed, number) = seed.random(100);

// Randomize the number by +-33%
uint number = 100;
(seed, number) = seed.randomize(number, 33);
```

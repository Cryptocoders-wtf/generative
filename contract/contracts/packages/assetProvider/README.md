# assetprovider.sol

## IAssetProvider

IAssetProvider is the interface which allows smart contracts to provide image assets for other smart contracts to use.

We assume there are three types of asset providers.
1. Static asset provider, which has a collection of assets (either in the storage or the code) and returns them.
2. Generative provider, which dynamically (but deterministically from the seed) generates assets.
3. Data visualizer, which generates assets based on various data on the blockchain.

Note: Asset providers MUST implements IERC165 (supportsInterface method) as well. 

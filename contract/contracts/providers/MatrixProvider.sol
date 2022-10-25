// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import "assetprovider.sol/IAssetProvider.sol";
import "randomizer.sol/Randomizer.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/interfaces/IERC165.sol';
import "hardhat/console.sol";
import "../interfaces/IColorSchemes.sol";

/**
 * MultiplexProvider create a new asset provider from another asset provider,
 * which draws multiple assets with the same set of provider-specific properties.
 */
contract MatrixProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint32;
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;

  string providerKey;
  string providerName;
  uint256 immutable providerAssetId;

  IAssetProvider public provider;
  IColorSchemes public colorSchemes;

  constructor(IAssetProvider _provider, IColorSchemes _colorSchemes, uint256 _assetId, string memory _key, string memory _name) {
    provider = _provider;
    colorSchemes = _colorSchemes;
    providerKey = _key;
    providerName = _name;
    providerAssetId = _assetId;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return
      interfaceId == type(IAssetProvider).interfaceId ||
      interfaceId == type(IERC165).interfaceId;
  }

  function getOwner() external override view returns (address) {
    return owner();
  }

  function getProviderInfo() external view override returns(ProviderInfo memory) {
    return ProviderInfo(providerKey, providerName, this);
  }

  function totalSupply() external pure override returns(uint256) {
    return 0; 
  }

  function processPayout(uint256) external override payable {
    // Notice that we don't use the specified _assetId. 
    provider.processPayout{value:msg.value}(providerAssetId);
  }

  function generateTraits(uint256 _assetId) external view returns (string memory) {
    return colorSchemes.generateTraits(_assetId);
  }

  struct Properties {
    string[] scheme;
    uint count;
    uint sizeVar;
  }

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    Properties memory props;
    Randomizer.Seed memory seed;
    (seed, props.scheme) = colorSchemes.getColorScheme(_assetId);
    (seed, props.count) = seed.random(18);
    props.count += 6;
    props.sizeVar = 18 - (props.count - 6) / 2;
    
    string memory defs;
    string memory tagPart;
    (defs, tagPart) = provider.generateSVGPart(providerAssetId);
    defs = string(abi.encodePacked(defs, '<filter id="grayscale">\n'
      '  <feColorMatrix type="saturate" values="0.00"/>\n'
      '</filter>\n'));
    bytes memory body;
    tag = string(abi.encodePacked(providerKey, _assetId.toString()));

    for (uint j = 0; j < 16; j++) {
      uint y = j * 64;
      for (uint i = 0; i < 16; i++) {
        uint colorIndex;
        (seed, colorIndex) = seed.random(props.scheme.length * 3);
        body = abi.encodePacked(body, '<use href="#', tagPart, '" fill="#', props.scheme[colorIndex % props.scheme.length]);
        if (colorIndex > props.scheme.length) {
          body = abi.encodePacked(body, '" filter="url(#grayscale)');          
        }
        uint x = i * 64;
        uint angle;
        (seed, angle) = seed.random(60);
        angle *= 60;
        body = abi.encodePacked(body, '" transform="translate(',
          x.toString(), ',', y.toString(),
          ') scale(0.0626, 0.0625) rotate(',angle.toString(),', 512, 512)" />\n');
      }
    }
    svgPart = string(abi.encodePacked(
      defs,
      '<g id="', tag, '">\n',
      body,
      '</g>\n'
    ));
  }
}
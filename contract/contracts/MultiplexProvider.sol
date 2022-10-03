// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IAssetProvider } from './interfaces/IAssetProvider.sol';
import { IAssetProviderEx } from './interfaces/IAssetProviderEx.sol';
import { ISVGHelper } from './interfaces/ISVGHelper.sol';
import './libs/Trigonometry.sol';
import './libs/Randomizer.sol';
import './libs/SVGHelper.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/interfaces/IERC165.sol';
import "hardhat/console.sol";

/**
 * MultiplexProvider create a new asset provider from another asset provider,
 * which draws multiple assets with the same set of provider-specific properties.
 */
contract MultiplexProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint32;
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Trigonometry for uint;

  string providerKey;
  string providerName;

  uint constant stylesPerSeed = 4;
  uint constant schemeCount = 11;
  uint constant colorCount = 5;

  IAssetProviderEx public provider;

  constructor(IAssetProviderEx _provider, string memory _key, string memory _name) {
    provider = _provider;
    providerKey = _key;
    providerName = _name;
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

  function processPayout(uint256 _assetId) external override payable {
    provider.processPayout(_assetId);
  }

  function getColorScheme(Randomizer.Seed memory _seed, uint256 _schemeIndex) internal pure returns(Randomizer.Seed memory seed, string[] memory scheme) {
    string[colorCount][schemeCount] memory schemes = [
      ["E9B4DB", "6160B0", "EB77A6", "3E3486", "E23D80"], // love
      ["FFDE91", "FF9D75", "DE6868", "494580", "BDA8FF"], // bright
      ["EDC9AF", "A0E2BD", "53CBCF", "0DA3BA", "046E94"], // beach
      ["FFE889", "88E7C5", "53BD99", "01767D", "034F4D"], // jungle
      ["D7F9F8", "FFFFEA", "FFF0D5", "FBE0E0", "E5D4EF"], // light
      ["801818", "3D0C02", "631934", "79224D", "682860"], // hair
      ["B3617B", "494C7D", "D0CEAC", "9BB797", "5C9A95"], // retro
      ["159F67", "66CA96", "EBFFF4", "F9BDB3", "F39385"], // sprint
      ["F9CC6C", "FD9A9C", "FEE4C6", "9DD067", "3D7F97"], // summer
      ["627AA3", "D8D0C5", "DAAE46", "7AAB9C", "9F4F4C"], // vintage
      ["5A261B", "C81125", "F15B4A", "FFAB63", "FADB6A"] // fall
    ];
    scheme = new string[](colorCount);
    uint offset;
    (seed, offset) = _seed.random(colorCount);
    for (uint i = 0; i < colorCount ; i++) {
      scheme[i] = schemes[_schemeIndex][(i + offset) % colorCount];
    }
  }

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    Randomizer.Seed memory seed = Randomizer.Seed(_assetId/stylesPerSeed, 0);
    uint schemeIndex;
    (seed, schemeIndex) = seed.random(schemeCount);

    string[] memory scheme;
    (seed, scheme) = getColorScheme(seed, schemeIndex);

    uint256 props;
    (seed, props) = provider.generateRandomProps(seed);
    
    bytes memory path;
    bytes memory body;

    if (_assetId % stylesPerSeed == 0) {
      (seed, path) = provider.generatePathWithProps(seed, props);
      body = abi.encodePacked('<path d="', path, '" fill="#', scheme[0], '" />\n');
    } else {
      seed = Randomizer.Seed(_assetId, 0);
      for (uint i = 0; i < scheme.length * 10; i++) {
        (seed, path) = provider.generatePathWithProps(seed, props);
        body = abi.encodePacked(body, '<path d="', path, '" fill="#', scheme[i / 10]);

        uint size;
        (seed, size) = seed.random(400);
        size += 100;
        uint margin = (1024 - 1024 * size / 1000) / 2;
        uint x;
        uint y;
        (seed, x) = seed.randomize(margin, 100);
        (seed, y) = seed.randomize(margin, 100);
        body = abi.encodePacked(body, '" transform="translate(',
          x.toString(), ',', y.toString(),
          ') scale(0.',size.toString(),', 0.',size.toString(),')" />\n');
      }
    }

    tag = string(abi.encodePacked(providerKey, _assetId.toString()));
    svgPart = string(abi.encodePacked(
      '<g id="', tag, '">\n',
      body,
      '</g>\n'
    ));
  }
}
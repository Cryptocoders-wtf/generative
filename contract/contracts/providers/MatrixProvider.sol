// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import 'assetprovider.sol/IAssetProvider.sol';
import 'randomizer.sol/Randomizer.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/interfaces/IERC165.sol';
import 'hardhat/console.sol';
import '../interfaces/IColorSchemes.sol';

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

  constructor(
    IAssetProvider _provider,
    IColorSchemes _colorSchemes,
    uint256 _assetId,
    string memory _key,
    string memory _name
  ) {
    provider = _provider;
    colorSchemes = _colorSchemes;
    providerKey = _key;
    providerName = _name;
    providerAssetId = _assetId;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IAssetProvider).interfaceId || interfaceId == type(IERC165).interfaceId;
  }

  function getOwner() external view override returns (address) {
    return owner();
  }

  function getProviderInfo() external view override returns (ProviderInfo memory) {
    return ProviderInfo(providerKey, providerName, this);
  }

  function totalSupply() external pure override returns (uint256) {
    return 0;
  }

  function processPayout(uint256) external payable override {
    // Notice that we don't use the specified _assetId.
    provider.processPayout{ value: msg.value }(providerAssetId);
  }

  function generateTraits(uint256 _assetId) external view returns (string memory) {
    return colorSchemes.generateTraits(_assetId);
  }

  struct Properties {
    string[] scheme;
  }

  function generateSVGPartWith(
    IAssetProvider _provider,
    string memory _providerKey,
    uint256 _providerAssetId,
    IColorSchemes _colorSchemes,
    uint256 _assetId
  ) public view returns (string memory svgPart, string memory tag) {
    Properties memory props;
    Randomizer.Seed memory seed;
    (seed, props.scheme) = _colorSchemes.getColorScheme(_assetId);

    string memory def;
    bytes memory defs;
    string[3] memory tagParts;
    (def, tagParts[0]) = _provider.generateSVGPart(_assetId);
    defs = bytes(def);
    (def, tagParts[1]) = _provider.generateSVGPart(_assetId + 1);
    defs = abi.encodePacked(defs, def);
    (def, tagParts[2]) = _provider.generateSVGPart(_assetId + 2);
    defs = abi.encodePacked(defs, def);
    bytes memory body;
    tag = string(abi.encodePacked(_providerKey, _assetId.toString()));

    bool[16][16] memory filled;

    for (uint j = 0; j < 16; j++) {
      uint y = j * 64;
      for (uint i = 0; i < 16; i++) {
        if (filled[i][j]) {
          continue;
        }

        uint index;
        (seed, index) = seed.random(props.scheme.length * 3);
        body = abi.encodePacked(
          body,
          '<use href="#',
          tagParts[index / props.scheme.length],
          '" fill="#',
          props.scheme[index % props.scheme.length]
        );

        string memory scale = '0.0625, 0.0625';
        (seed, index) = seed.random(100);
        if (i % 2 == 0 && j % 2 == 0) {
          if (i % 8 == 0 && j % 8 == 0 && index < 18) {
            scale = '0.5, 0.5';
            for (uint k = 0; k < 64; k++) {
              filled[i + (k % 8)][j + k / 8] = true;
            }
          } else if (i % 4 == 0 && j % 4 == 0 && index < 50) {
            scale = '0.25, 0.25';
            for (uint k = 0; k < 16; k++) {
              filled[i + (k % 4)][j + k / 4] = true;
            }
          } else if (index < 80) {
            scale = '0.125, 0.125';
            filled[i + 1][j] = true;
            filled[i][j + 1] = true;
            filled[i + 1][j + 1] = true;
          }
        }

        uint x = i * 64;
        uint angle;
        (seed, angle) = seed.random(60);
        angle *= 60;
        body = abi.encodePacked(
          body,
          '" transform="translate(',
          x.toString(),
          ',',
          y.toString(),
          ') scale(',
          scale,
          ') rotate(',
          angle.toString(),
          ', 512, 512)" />\n'
        );
      }
    }
    svgPart = string(abi.encodePacked(defs, '<g id="', tag, '">\n', body, '</g>\n'));
  }

  function generateSVGPart(uint256 _assetId) external view override returns (string memory svgPart, string memory tag) {
    return generateSVGPartWith(provider, providerKey, providerAssetId, colorSchemes, _assetId);
  }
}

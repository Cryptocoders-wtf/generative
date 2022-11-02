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
import { IAssetProviderEx } from '../interfaces/IAssetProviderEx.sol';
import "assetprovider.sol/ISVGHelper.sol";
import "randomizer.sol/Randomizer.sol";
import "trigonometry.sol/Trigonometry.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/interfaces/IERC165.sol';
import "hardhat/console.sol";

contract StarProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint;
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Trigonometry for uint;

  struct Props {
    uint thickness; 
    uint style; // 0 or 1
    uint growth; // average size of growth
  }

  string constant providerKey = "snow";
  address public receiver;
  ISVGHelper svgHelper;

  constructor(ISVGHelper _svgHelper) {
    receiver = owner();
    svgHelper = _svgHelper; // default helper
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return
      interfaceId == type(IAssetProvider).interfaceId ||
      interfaceId == type(IAssetProviderEx).interfaceId ||
      interfaceId == type(IERC165).interfaceId;
  }

  function getOwner() external override view returns (address) {
    return owner();
  }

  function getProviderInfo() external view override returns(ProviderInfo memory) {
    return ProviderInfo(providerKey, "Snow Flakes", this);
  }

  function totalSupply() external pure override returns(uint256) {
    return 0; // indicating "dynamically (but deterministically) generated from the given assetId)
  }

  function processPayout(uint256 _assetId) external override payable {
    address payable payableTo = payable(receiver);
    payableTo.transfer(msg.value);
    emit Payout(providerKey, _assetId, payableTo, msg.value);
  }

  function setReceiver(address _receiver) onlyOwner external {
    receiver = _receiver;
  }

  function setHelper(ISVGHelper _svgHelper) external onlyOwner {
    svgHelper = _svgHelper;
  }

  function generatePoints(Randomizer.Seed memory _seed, Props memory _props) pure internal 
                returns(Randomizer.Seed memory, uint[] memory) {
    uint count = 12;
    int radius = 500;
    uint[] memory points = new uint[](count);    
    for (uint i=0; i < count; i++) {
      uint angle = 0x4000 * i / count;
      uint x = uint(angle.cos() * radius / 0x8000 + 512);
      uint y = uint(angle.sin() * radius / 0x8000 + 512);
      points[i] = x + y << 16 + (566 << 32);
    }
    return (_seed, points);
  }

  function generatePath(Randomizer.Seed memory _seed, Props memory _props) public view returns(Randomizer.Seed memory seed, bytes memory svgPart) {
    uint[] memory points;
    (seed, points) = generatePoints(_seed, _props);
    svgPart = svgHelper.pathFromPoints(points);
  }

  function generateProps(Randomizer.Seed memory _seed) public pure returns(Randomizer.Seed memory seed, Props memory props) {
    seed = _seed;
    props = Props(400, 40, 100);
    (seed, props.thickness) = seed.randomize(props.thickness, 60); // +/- 60%
    (seed, props.style) = seed.random(2); // 0 or 1
    (seed, props.growth) = seed.random(7);
    props.growth += 100;
  }

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    Randomizer.Seed memory seed = Randomizer.Seed(_assetId, 0);
    Props memory props;
    (seed, props) = generateProps(seed);

    bytes memory path;
    (,path) = generatePath(seed, props);

    tag = string(abi.encodePacked(providerKey, _assetId.toString()));
    svgPart = string(abi.encodePacked(
      '<g id="', tag, '">\n'
      '<path d="', path, '"/>\n'
      '</g>\n'
    ));
  }

  function generateTraits(uint256 _assetId) external pure override returns (string memory traits) {
    // nothing to return
  }
}
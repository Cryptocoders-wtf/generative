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

contract SnowProvider is IAssetProviderEx, IERC165, Ownable {
  using Strings for uint32;
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Trigonometry for uint;

  struct Props {
    uint thickness; 
    uint length; // average length fo arm
    uint dot; // average size of dot
  }

  string constant providerKey = "snow";
  address public receiver;
  ISVGHelper svgHelper;

  constructor() {
    receiver = owner();
    svgHelper = new SVGHelper(); // default helper
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

  function generatePoints(Randomizer.Seed memory _seed, Props memory _props) pure internal returns(Randomizer.Seed memory, ISVGHelper.Point[] memory) {
    Randomizer.Seed memory seed = _seed;
    int32 r = 480;
    int32 army = int32(int256(_props.thickness));
    int32 armx = (army * 173) / 100;
    uint count = uint(int(r / army));
    ISVGHelper.Point[] memory points = new ISVGHelper.Point[](count * 2 + 2);
    points[0].x = 512;
    points[0].y = 512;
    points[0].c = true;
    points[0].r = 0;
    points[1].x = 512;
    points[1].y = 512 + r;
    points[1].c = true;
    points[1].r = 0;
    ISVGHelper.Point memory point;
    point.c = false;
    point.r = 566;
    for (uint i=0; i<count; i++) {
      point.x = 512 + armx * (1 + int32(int(i % 2)));
      point.y = 512 + r + army;
      points[2 + i * 2] = point;
      point.y = 512 + r;
      points[3 + i * 2] = point;
      r -= army;
    }
    return (seed, points);
  }

  function generatePath(Randomizer.Seed memory _seed, Props memory _props) public view returns(Randomizer.Seed memory seed, bytes memory svgPart) {
    ISVGHelper.Point[] memory points;
    (seed, points) = generatePoints(_seed, _props);
    svgPart = svgHelper.PathFromPoints(points);
  }

  function generateProps(Randomizer.Seed memory _seed) public pure returns(Randomizer.Seed memory seed, Props memory props) {
    seed = _seed;
    props = Props(40, 40, 100);
    (seed, props.thickness) = seed.randomize(props.thickness, 60); // +/- 60%
    (seed, props.length) = seed.randomize(props.length, 50); // +/- 50%
    (seed, props.dot) = seed.randomize(props.dot, 50);
  }

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    Randomizer.Seed memory seed = Randomizer.Seed(_assetId, 0);
    Props memory props;
    (seed, props) = generateProps(seed);

    bytes memory path;
    (,path) = generatePath(seed, props);

    tag = string(abi.encodePacked(providerKey, _assetId.toString()));
    bytes memory part = abi.encodePacked(
      '<g id="', tag, 'part">\n'
      '<path d="', path, '"/>\n'
      '</g>\n'
    );
    part = abi.encodePacked(
      part,
      '<g id="', tag, '">\n');
    for (uint i = 0; i < 360; i += 60) {
      part = abi.encodePacked(
        part,
        '<use href="#', tag, 'part" transform="rotate(', i.toString(),', 512, 512)"/>\n',
        '<use href="#', tag, 'part" transform="rotate(', i.toString(),', 512, 512) scale(-1, 1) translate(-1024, 0)"/>\n'
      );
    }
    part = abi.encodePacked(
      part,
      '</g>\n'
    );
    svgPart = string(part);
  }

  /**
   * An optional method, which allows MultplexProvider to create a new set of assets.
   */
  function generateRandomProps(Randomizer.Seed memory _seed) external override pure returns(Randomizer.Seed memory seed, uint256 prop) {
    Props memory props;
    (seed, props) = generateProps(_seed);
    prop = props.thickness + props.length * 0x10000 + props.dot * 0x100000000;
  }

  /**
   * An optional method, which allows MultplexProvider to create a new set of assets.
   */
  function generatePathWithProps(Randomizer.Seed memory _seed, uint256 _prop) external override view returns(Randomizer.Seed memory seed, bytes memory svgPart) {
    Props memory props;
    props.thickness = _prop & 0xffff;
    props.length = (_prop / 0x10000) & 0xffff;
    props.dot = (_prop / 0x100000000) & 0xffff;
    return generatePath(_seed, props);
  }
}
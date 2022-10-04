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
import "randomizer.sol/Randomizer.sol";
import './libs/SVGHelper.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/interfaces/IERC165.sol';
import "hardhat/console.sol";

contract SnowProvider is IAssetProviderEx, IERC165, Ownable {
  using Strings for uint32;
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;

  struct Props {
    uint thickness; 
    uint style; // 0 or 1
    uint growth; // average size of growth
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
    int32 thickness = int32(int256(_props.thickness));
    int32 army = thickness / 10;
    int32 armx = (army * 173) / 100;
    int32 r = 512;
    if (_props.style == 0) {
      r -= army * 2;
    }
    int32 dir = (_props.style == 0)? int32(1) : int32(-1);
    uint count = uint(int(r / army)) - 1;
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
    for (uint i=0; i < count * 2; i++) {
      int32 m = (i % 4 < 2) ? int32(2) : int32(1); 
      point.x = 512 + m * armx; //  * (1 + int32(int(i % 2)));
      if (i % 2 == 0) {
        point.y = 512 + r + dir * m * army;
      } else {
        point.y = 512 + r + dir * m * army - army;
        r -= army;
        thickness = thickness * int32(int(_props.growth)) / 100;
        army = thickness / 10;
        armx = (army * 173) / 100;
      }
      // Work-around a compiler bug (points[i+2] = point)
      points[i + 2].x = point.x;
      points[i + 2].y = point.y;
      points[i + 2].c = point.c;
      points[i + 2].r = point.r;
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
    props = Props(400, 40, 100);
    (seed, props.thickness) = seed.randomize(props.thickness, 60); // +/- 60%
    (seed, props.style) = seed.random(2); // 0 or 1
    (seed, props.growth) = seed.random(7);
    props.growth += 100;
  }

  function SVGPartFromPath(bytes memory _path, string memory _tag) internal pure returns(string memory svgPart) {
    bytes memory part = abi.encodePacked(
      '<g id="', _tag, 'part">\n'
      '<path d="', _path, '"/>\n'
      '</g>\n'
    );
    part = abi.encodePacked(
      part,
      '<g id="', _tag, '">\n');
    for (uint i = 0; i < 360; i += 60) {
      part = abi.encodePacked(
        part,
        '<use href="#', _tag, 'part" transform="rotate(', i.toString(),', 512, 512)"/>\n',
        '<use href="#', _tag, 'part" transform="rotate(', i.toString(),', 512, 512) scale(-1, 1) translate(-1024, 0)"/>\n'
      );
    }
    part = abi.encodePacked(
      part,
      '</g>\n'
    );
    svgPart = string(part);
  }

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    Randomizer.Seed memory seed = Randomizer.Seed(_assetId, 0);
    Props memory props;
    (seed, props) = generateProps(seed);

    bytes memory path;
    (,path) = generatePath(seed, props);

    tag = string(abi.encodePacked(providerKey, _assetId.toString()));
    svgPart = SVGPartFromPath(path, tag);
  }

  /**
   * An optional method, which allows MultplexProvider to create a new set of assets.
   */
  function generateRandomProps(Randomizer.Seed memory _seed) external override pure returns(Randomizer.Seed memory seed, uint256 prop) {
    Props memory props;
    (seed, props) = generateProps(_seed);
    prop = props.thickness + props.style * 0x10000 + props.growth * 0x100000000;
  }

  /**
   * An optional method, which allows MultplexProvider to create a new set of assets.
   */
  function generateSVGPartWithProps(Randomizer.Seed memory _seed, uint256 _prop, string memory _tag) external override view 
    returns(Randomizer.Seed memory seed, string memory svgPart) {
    Props memory props;
    props.thickness = _prop & 0xffff;
    props.style = (_prop / 0x10000) & 0xffff;
    props.growth = (_prop / 0x100000000) & 0xffff;
    bytes memory path;
    (seed, path) = generatePath(_seed, props);
    svgPart = SVGPartFromPath(path, _tag);
  }
}
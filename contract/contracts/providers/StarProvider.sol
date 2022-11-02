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
import "../packages/graphics/Vector.sol";
import "../packages/graphics/Path.sol";
import "hardhat/console.sol";

contract StarProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint;
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Trigonometry for uint;
  using Vector for Vector.Struct;
  using Path for uint[];

  struct Props {
    uint count; // number of control points
    uint length; // average length fo arm
  }

  string constant providerKey = "snow";
  address public receiver;

  constructor() {
    receiver = owner();
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

  function generatePath(Props memory _props) public pure returns(bytes memory path) {
    uint count = _props.count;
    int radius = 511;
    int length = int(_props.length);
    Vector.Struct memory center = Vector.vector(512, 512);
    uint[] memory points = new uint[](count * 2);    
    for (uint i = 0; i < count * 2; i += 2) {
      int angle = int(0x4000 * i / count / 2);
      Vector.Struct memory vector = Vector.vectorWithAngle(angle, radius);
      points[i] = Path.roundedCorner(vector.add(center));
      points[i+1] = Path.sharpCorner(vector.mul(length).div(100).rotate(int(0x4000 / count / 2)).add(center));
    }
    path = points.closedPath();
  }

  function generateProps(uint256 _assetId) public pure returns(Randomizer.Seed memory seed, Props memory props) {
    seed = Randomizer.Seed(_assetId, 0);
    props = Props(30, 40);
    (seed, props.count) = seed.randomize(props.count, 50); // +/- 50%
    (seed, props.length) = seed.randomize(props.length, 50); // +/- 50%
  }

  function generateSVGPart(uint256 _assetId) external pure override returns(string memory svgPart, string memory tag) {
    Props memory props;
    (, props) = generateProps(_assetId);
    bytes memory path = generatePath(props);
    tag = string(abi.encodePacked(providerKey, _assetId.toString()));
    svgPart = string(abi.encodePacked(
      '<path id="', tag, '" d="', path, '"/>\n'
    ));
  }

  function generateTraits(uint256 _assetId) external pure override returns (string memory traits) {
    // nothing to return
  }
}
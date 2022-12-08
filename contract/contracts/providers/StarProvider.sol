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
import '../packages/graphics/Path.sol';
import '../packages/graphics/SVG.sol';
import 'hardhat/console.sol';

contract StarProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Vector for Vector.Struct;
  using Path for uint[];
  using SVG for SVG.Element;

  struct Props {
    uint count; // number of spikes
    uint length; // relative length of each valley (percentile)
  }

  string constant providerKey = 'snow';
  address public receiver;

  constructor() {
    receiver = owner();
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IAssetProvider).interfaceId || interfaceId == type(IERC165).interfaceId;
  }

  function getOwner() external view override returns (address) {
    return owner();
  }

  function getProviderInfo() external view override returns (ProviderInfo memory) {
    return ProviderInfo(providerKey, 'Snow Flakes', this);
  }

  function totalSupply() external pure override returns (uint256) {
    return 0; // indicating "dynamically (but deterministically) generated from the given assetId)
  }

  function processPayout(uint256 _assetId) external payable override {
    address payable payableTo = payable(receiver);
    payableTo.transfer(msg.value);
    emit Payout(providerKey, _assetId, payableTo, msg.value);
  }

  function setReceiver(address _receiver) external onlyOwner {
    receiver = _receiver;
  }

  function generatePath(Props memory _props) public pure returns (bytes memory path) {
    uint count = _props.count;
    int radius = 511; // We want to fill the whole viewbox (1024 x 1024)
    int length = int(_props.length);
    Vector.Struct memory center = Vector.vector(512, 512); // center of the viewbox
    uint[] memory points = new uint[](count * 2);
    for (uint i = 0; i < count * 2; i += 2) {
      int angle = (Vector.PI2 * int(i)) / int(count) / 2;
      Vector.Struct memory vector = Vector.vectorWithAngle(angle, radius);
      points[i] = Path.roundedCorner(vector.add(center));
      points[i + 1] = Path.sharpCorner(vector.mul(length).div(100).rotate(Vector.PI2 / int(count) / 2).add(center));
    }
    path = points.closedPath();
  }

  function generateProps(uint256 _assetId) public pure returns (Randomizer.Seed memory seed, Props memory props) {
    seed = Randomizer.Seed(_assetId, 0);
    (seed, props.count) = seed.randomize(30, 50); // +/- 50%
    (seed, props.length) = seed.randomize(40, 50); // +/- 50%
  }

  function generateSVGPart(uint256 _assetId) public pure override returns (string memory svgPart, string memory tag) {
    Props memory props;
    (, props) = generateProps(_assetId);
    bytes memory path = generatePath(props);
    tag = string(abi.encodePacked(providerKey, _assetId.toString()));
    svgPart = string(SVG.path(path).id(tag).svg());
  }

  function generateTraits(uint256 _assetId) external pure override returns (string memory traits) {
    // nothing to return
  }

  // For debugging
  function generateSVGDocument(uint256 _assetId) external pure returns (string memory svgDocument) {
    string memory svgPart;
    string memory tag;
    (svgPart, tag) = generateSVGPart(_assetId);
    svgDocument = string(SVG.document('0 0 1024 1024', bytes(svgPart), SVG.use(tag).svg()));
  }
}

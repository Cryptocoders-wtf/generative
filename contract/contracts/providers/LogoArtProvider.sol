// SPDX-License-Identifier: MIT

/*
 * Created by Isamu Arimoto (@isamua)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import 'assetprovider.sol/IAssetProvider.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/interfaces/IERC165.sol';
// import "../packages/graphics/Path.sol";
import '../packages/graphics/SVG.sol';

import '../imageParts/interfaces/ISVGArt.sol';

contract LogoArtProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint256;
  // using Vector for Vector.Struct;
  // using Path for uint[];
  using SVG for SVG.Element;

  ISVGArt immutable svgArt;

  string constant providerKey = 'Logo1';
  address public receiver;

  constructor(ISVGArt _svgArt) {
    svgArt = _svgArt;
    receiver = owner();
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IAssetProvider).interfaceId || interfaceId == type(IERC165).interfaceId;
  }

  function getOwner() external view override returns (address) {
    return owner();
  }

  function getProviderInfo() external view override returns (ProviderInfo memory) {
    return ProviderInfo(providerKey, 'Logo', this);
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

  function generateSVGPart(uint256 _assetId) public view override returns (string memory svgPart, string memory tag) {
    // TODO: Must update if the number of variations of LuArt1 increases
    bytes memory path = svgArt.getSVGBody(uint16(_assetId));

    tag = string(abi.encodePacked(providerKey, _assetId.toString()));
    svgPart = string(path);
  }

  function generateTraits(uint256 _assetId) external pure override returns (string memory traits) {
    // nothing to return
  }

  // For debugging
  function generateSVGDocument(uint256 _assetId) external view returns (string memory svgDocument) {
    string memory svgPart;
    string memory tag;
    (svgPart, tag) = generateSVGPart(_assetId);
    SVG.Element[] memory samples = new SVG.Element[](0);
    svgDocument = string(SVG.document('0 0 1024 1024', SVG.list(samples).svg(), bytes(svgPart)));
  }
}

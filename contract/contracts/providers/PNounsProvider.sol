// SPDX-License-Identifier: MIT

/**
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import "assetprovider.sol/IAssetProvider.sol";
import "randomizer.sol/Randomizer.sol";
import '@openzeppelin/contracts/interfaces/IERC165.sol';
import "../packages/graphics/Path.sol";
import "../packages/graphics/SVG.sol";
import "../packages/graphics/Text.sol";
import "../packages/graphics/IFontProvider.sol";

contract PNounsPrivider is IAssetProvider, Ownable, IERC165 {
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Vector for Vector.Struct;
  using Path for uint[];
  using SVG for SVG.Element;
  using TX for string;
  using Trigonometry for uint;

  IFontProvider immutable font;
  
  constructor(IFontProvider _font) {
    font = _font;
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
    return ProviderInfo("pnouns", "pNouns", this);
  }

  function totalSupply() external pure override returns(uint256) {
    return 0;
  }

  function processPayout(uint256 _assetId) external override payable {
    address payable payableTo = payable(owner());
    payableTo.transfer(msg.value);
    emit Payout("pnouns", _assetId, payableTo, msg.value);
  }

  function generateTraits(uint256 _assetId) external pure override returns (string memory traits) {
    // nothing to return
  }

  function generateSVGPart(uint256 _assetId) external pure override returns(string memory svgPart, string memory tag) {
    tag = string(abi.encodePacked("circles", _assetId.toString()));
    svgPart = "abc";
  }
}
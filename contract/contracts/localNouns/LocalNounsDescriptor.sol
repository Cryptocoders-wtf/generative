// SPDX-License-Identifier: GPL-3.0

/// @title The Nouns NFT descriptor

/*********************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *********************************/

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import { INounsDescriptor } from './interfaces/INounsDescriptor.sol';
import { INounsSeeder } from './interfaces/INounsSeeder.sol';
import { MultiPartRLEToSVG } from '../external/nouns/libs/MultiPartRLEToSVG.sol';
import { NFTDescriptor } from '../external/nouns/libs/NFTDescriptor.sol';

contract LocalNounsDescriptor is INounsDescriptor, Ownable {
  using Strings for uint256;

  // original
  INounsDescriptor public immutable descriptor;

  // prettier-ignore
  // https://creativecommons.org/publicdomain/zero/1.0/legalcode.txt
  bytes32 constant COPYRIGHT_CC0_1_0_UNIVERSAL_LICENSE = 0xa2010f343487d3f7618affe54f789f5487602331c0a8d03f49e9a7c547cf0499;

  // Whether or not new Noun parts can be added
  bool public override arePartsLocked;

  // Whether or not `tokenURI` should be returned as a data URI (Default: true)
  bool public override isDataURIEnabled = true;

  // Base URI
  string public override baseURI;

  // Noun Color Palettes (Index => Hex Colors)
  mapping(uint8 => string[]) public override palettes;

  // Noun Backgrounds (Hex Colors)
  string[] public override backgrounds;

  // Noun Bodies (Custom RLE)
  bytes[] public override bodies;

  // Noun Accessories (Custom RLE)
  bytes[] public override accessories;

  // Noun Heads (Custom RLE)
  bytes[] public override heads;

  // Noun Glasses (Custom RLE)
  bytes[] public override glasses;

  // prefectureId => parts index of heads
  mapping(uint256 => uint256[]) public prefectureHeads;

  // prefectureId => parts index of accessories
  mapping(uint256 => uint256[]) public prefectureAccessories;

  // parts index => parts name of heads
  mapping(uint256 => string) public headsName;

  // parts index => parts name of accessories
  mapping(uint256 => string) public AccessoriesName;

  constructor(INounsDescriptor _descriptor) {
    descriptor = _descriptor;
  }

  /**
   * @notice Require that the parts have not been locked.
   */
  modifier whenPartsNotLocked() {
    require(!arePartsLocked, 'Parts are locked');
    _;
  }

  /**
   * @notice Get the number of available Noun `backgrounds`.
   */
  function backgroundCount() external view override returns (uint256) {
    return backgrounds.length;
  }

  /**
   * @notice Get the number of available Noun `bodies`.
   */
  function bodyCount() external view override returns (uint256) {
    return descriptor.bodyCount();
    // return bodies.length;
  }

  /**
   * @notice Get the number of available Noun `accessories`.
   */
  function accessoryCount() external view override returns (uint256) {
    return accessories.length;
  }

  /**
   * @notice Get the number of available Noun `accessories` in the prefecture.
   */
  function accessoryCountInPrefecture(uint256 prefectureId) external view override returns (uint256) {
    return prefectureAccessories[prefectureId].length;
  }

  /**
   * @notice Get the number of available Noun `accessories` in the prefecture.
   */
  function accessoryInPrefecture(uint256 prefectureId, uint256 seqNo) external view override returns (uint256) {
    return prefectureAccessories[prefectureId][seqNo];
  }

  /**
   * @notice Get the name of accessories.
   */
  function accessoryName(uint256 _partsId) external view override returns (string memory) {
    return AccessoriesName[_partsId];
  }

  /**
   * @notice Get the number of available Noun `heads`.
   */
  function headCount() external view override returns (uint256) {
    return heads.length;
  }

  /**
   * @notice Get the number of available Noun `heads` in the prefecture.
   */
  function headCountInPrefecture(uint256 prefectureId) external view override returns (uint256) {
    return prefectureHeads[prefectureId].length;
  }

  /**
   * @notice Get the number of available Noun `heads` in the prefecture.
   */
  function headInPrefecture(uint256 prefectureId, uint256 seqNo) external view override returns (uint256) {
    return prefectureHeads[prefectureId][seqNo];
  }

  /**
   * @notice Get the name of heads.
   */
  function headName(uint256 _partsId) external view override returns (string memory) {
    return headsName[_partsId];
  }

  /**
   * @notice Get the number of available Noun `glasses`.
   */
  function glassesCount() external view override returns (uint256) {
    return descriptor.glassesCount();
    // return glasses.length;
  }

  /**
   * @notice Add colors to a color palette.
   * @dev This function can only be called by the owner.
   */
  function addManyColorsToPalette(uint8 paletteIndex, string[] calldata newColors) external override onlyOwner {
    require(palettes[paletteIndex].length + newColors.length <= 256, 'Palettes can only hold 256 colors');
    for (uint256 i = 0; i < newColors.length; i++) {
      _addColorToPalette(paletteIndex, newColors[i]);
    }
  }

  /**
   * @notice Batch add Noun backgrounds.
   * @dev This function can only be called by the owner when not locked.
   */
  function addManyBackgrounds(string[] calldata _backgrounds) external override onlyOwner whenPartsNotLocked {
    for (uint256 i = 0; i < _backgrounds.length; i++) {
      _addBackground(_backgrounds[i]);
    }
  }

  /**
   * @notice Batch add Noun bodies.
   * @dev This function can only be called by the owner when not locked.
   */
  function addManyBodies(bytes[] calldata _bodies) external override onlyOwner whenPartsNotLocked {
    for (uint256 i = 0; i < _bodies.length; i++) {
      _addBody(_bodies[i]);
    }
  }

  /**
   * @notice Batch add Noun accessories.
   * @dev This function can only be called by the owner when not locked.
   */
  function addManyAccessories(
    uint256 prefectureId,
    bytes[] calldata _accessories,
    string[] calldata _names
  ) external override onlyOwner whenPartsNotLocked {
    for (uint256 i = 0; i < _accessories.length; i++) {
      _addAccessory(prefectureId, _accessories[i], _names[i]);
    }
  }

  /**
   * @notice Batch add Noun heads.
   * @dev This function can only be called by the owner when not locked.
   */
  function addManyHeads(
    uint256 prefectureId,
    bytes[] calldata _heads,
    string[] calldata _names
  ) external override onlyOwner whenPartsNotLocked {
    for (uint256 i = 0; i < _heads.length; i++) {
      _addHead(prefectureId, _heads[i], _names[i]);
    }
  }

  /**
   * @notice Batch add Noun glasses.
   * @dev This function can only be called by the owner when not locked.
   */
  function addManyGlasses(bytes[] calldata _glasses) external override onlyOwner whenPartsNotLocked {
    for (uint256 i = 0; i < _glasses.length; i++) {
      _addGlasses(_glasses[i]);
    }
  }

  /**
   * @notice Add a single color to a color palette.
   * @dev This function can only be called by the owner.
   */
  function addColorToPalette(uint8 _paletteIndex, string calldata _color) external override onlyOwner {
    require(palettes[_paletteIndex].length <= 255, 'Palettes can only hold 256 colors');
    _addColorToPalette(_paletteIndex, _color);
  }

  /**
   * @notice Add a Noun background.
   * @dev This function can only be called by the owner when not locked.
   */
  function addBackground(string calldata _background) external override onlyOwner whenPartsNotLocked {
    _addBackground(_background);
  }

  /**
   * @notice Add a Noun body.
   * @dev This function can only be called by the owner when not locked.
   */
  function addBody(bytes calldata _body) external override onlyOwner whenPartsNotLocked {
    _addBody(_body);
  }

  /**
   * @notice Add a Noun accessory.
   * @dev This function can only be called by the owner when not locked.
   */
  function addAccessory(
    uint256 prefectureId,
    bytes calldata _accessory,
    string calldata _name
  ) external override onlyOwner whenPartsNotLocked {
    _addAccessory(prefectureId, _accessory, _name);
  }

  /**
   * @notice Add a Noun head.
   * @dev This function can only be called by the owner when not locked.
   */
  function addHead(
    uint256 prefectureId,
    bytes calldata _head,
    string calldata _name
  ) external override onlyOwner whenPartsNotLocked {
    _addHead(prefectureId, _head, _name);
  }

  /**
   * @notice Add Noun glasses.
   * @dev This function can only be called by the owner when not locked.
   */
  function addGlasses(bytes calldata _glasses) external override onlyOwner whenPartsNotLocked {
    _addGlasses(_glasses);
  }

  /**
   * @notice Lock all Noun parts.
   * @dev This cannot be reversed and can only be called by the owner when not locked.
   */
  function lockParts() external override onlyOwner whenPartsNotLocked {
    arePartsLocked = true;

    emit PartsLocked();
  }

  /**
   * @notice Toggle a boolean value which determines if `tokenURI` returns a data URI
   * or an HTTP URL.
   * @dev This can only be called by the owner.
   */
  function toggleDataURIEnabled() external override onlyOwner {
    bool enabled = !isDataURIEnabled;

    isDataURIEnabled = enabled;
    emit DataURIToggled(enabled);
  }

  /**
   * @notice Set the base URI for all token IDs. It is automatically
   * added as a prefix to the value returned in {tokenURI}, or to the
   * token ID if {tokenURI} is empty.
   * @dev This can only be called by the owner.
   */
  function setBaseURI(string calldata _baseURI) external override onlyOwner {
    baseURI = _baseURI;

    emit BaseURIUpdated(_baseURI);
  }

  /**
   * @notice Given a token ID and seed, construct a token URI for an official Nouns DAO noun.
   * @dev The returned value may be a base64 encoded data URI or an API URL.
   */
  function tokenURI(uint256 tokenId, INounsSeeder.Seed memory seed) external view override returns (string memory) {
    if (isDataURIEnabled) {
      return dataURI(tokenId, seed);
    }
    return string(abi.encodePacked(baseURI, tokenId.toString()));
  }

  /**
   * @notice Given a token ID and seed, construct a base64 encoded data URI for an official Nouns DAO noun.
   */
  function dataURI(uint256 tokenId, INounsSeeder.Seed memory seed) public view override returns (string memory) {
    string memory nounId = tokenId.toString();
    string memory name = string(abi.encodePacked('Noun ', nounId));
    string memory description = string(abi.encodePacked('Noun ', nounId, ' is a member of the Nouns DAO'));

    return genericDataURI(name, description, seed);
  }

  /**
   * @notice Given a name, description, and seed, construct a base64 encoded data URI.
   */
  function genericDataURI(
    string memory name,
    string memory description,
    INounsSeeder.Seed memory seed
  ) public view override returns (string memory) {
    NFTDescriptor.TokenURIParams memory params = NFTDescriptor.TokenURIParams({
      name: name,
      description: description,
      parts: _getPartsForSeed(seed),
      background: descriptor.backgrounds(seed.background)
    });
    return NFTDescriptor.constructTokenURI(params, palettes);
  }

  /**
   * @notice Given a seed, construct a base64 encoded SVG image.
   */
  function generateSVGImage(INounsSeeder.Seed memory seed) external view override returns (string memory) {
    MultiPartRLEToSVG.SVGParams memory params = MultiPartRLEToSVG.SVGParams({
      parts: _getPartsForSeed(seed),
      background: descriptor.backgrounds(seed.background)
    });
    return NFTDescriptor.generateSVGImage(params, palettes);
  }

  /**
   * @notice Add a single color to a color palette.
   */
  function _addColorToPalette(uint8 _paletteIndex, string calldata _color) internal {
    palettes[_paletteIndex].push(_color);
  }

  /**
   * @notice Add a Noun background.
   */
  function _addBackground(string calldata _background) internal {
    backgrounds.push(_background);
  }

  /**
   * @notice Add a Noun body.
   */

  function _addBody(bytes calldata _body) internal {
    // nothing
    // bodies.push(_body);
  }

  /**
   * @notice Add a Noun accessory.
   */
  function _addAccessory(uint256 prefectureId, bytes calldata _accessory, string calldata _name) internal {
    prefectureAccessories[prefectureId].push(accessories.length);
    AccessoriesName[accessories.length] = _name;
    accessories.push(_accessory);
  }

  /**
   * @notice Add a Noun head.
   */
  function _addHead(uint256 prefectureId, bytes calldata _head, string calldata _name) internal {
    prefectureHeads[prefectureId].push(heads.length);
    headsName[heads.length] = _name;
    heads.push(_head);
  }

  /**
   * @notice Add Noun glasses.
   */
  function _addGlasses(bytes calldata _glasses) internal {
    // glasses.push(_glasses);
  }

  /**
   * @notice Get all Noun parts for the passed `seed`.
   */
  function _getPartsForSeed(INounsSeeder.Seed memory seed) internal view returns (bytes[] memory) {
    bytes[] memory _parts = new bytes[](4);
    _parts[0] = descriptor.bodies(seed.body);
    _parts[1] = accessories[seed.accessory];
    _parts[2] = heads[seed.head];
    _parts[3] = descriptor.glasses(seed.glasses);
    return _parts;
  }
}

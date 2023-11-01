// SPDX-License-Identifier: MIT

/*
 * Created by Takuya Mizutani (@Takuya-Mizutani)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import 'assetprovider.sol/IAssetProvider.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/interfaces/IERC165.sol';
import '../packages/graphics/SVG.sol';

import '../imageParts/interfaces/IMessageStoreV2.sol';

contract MessageProvider3 is IAssetProvider, IERC165, Ownable {
  using Strings for uint256;
  using SVG for SVG.Element;

  IMessageStoreV2 immutable messageStore;

  string constant providerKey = 'MessageV3';
  address public receiver;

  mapping(string => IAssetProvider) public assets;

  constructor(IMessageStoreV2 _messageStore) {
    messageStore = _messageStore;
    receiver = owner();
  }

  function registerAsset(string memory assetName, IAssetProvider assetProvider) external {
    assets[assetName] = assetProvider;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IAssetProvider).interfaceId || interfaceId == type(IERC165).interfaceId;
  }

  function getOwner() external view override returns (address) {
    return owner();
  }

  function getProviderInfo() external view override returns (ProviderInfo memory) {
    return ProviderInfo(providerKey, 'Message', this);
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
    bytes memory path = messageStore.getSVGBody(_assetId);
    tag = string(abi.encodePacked(providerKey, _assetId.toString()));

    IMessageStoreV2.Asset memory asset = messageStore.getAsset(_assetId);
    string memory assetName = asset.assetName;
    IAssetProvider assetProvider = assets[assetName];

    (string memory noPart, string memory noTag) = assetProvider.generateSVGPart(_assetId);

    bytes memory body = abi.encodePacked('<g opacity="0.4">', bytes(noPart), '</g>', '<g>\n', path, '</g>\n');

    svgPart = string(SVG.group(body).id(tag).svg());
  }

  function generateTraits(uint256 _assetId) external pure override returns (string memory traits) {
    // nothing to return
  }

  // For debugging
  function generateSVGDocument(uint256 _assetId) external view returns (string memory svgDocument) {
    string memory svgPart;
    string memory tag;
    (svgPart, tag) = generateSVGPart(_assetId);
    svgDocument = string(SVG.document('0 0 1024 1024', bytes(svgPart), SVG.use(tag).svg()));
  }

  function generateSVGMessage(
    string memory message, 
    string memory color, 
    string memory fontName, 
    string memory assetName, 
    IMessageStoreV2.Box memory box
  ) public view returns (string memory output) {
    // Text
    bytes memory path = messageStore.getSVGBodyFromAsset(message, color, fontName, box); 

    // Background
    uint256 _assetId = messageStore.getNextPartIndex();
    string memory tag = string(abi.encodePacked(providerKey, _assetId.toString()));

    (string memory noPart, string memory noTag) = assets[assetName].generateSVGPart(_assetId);
    bytes memory body = abi.encodePacked('<g opacity="0.4">', bytes(noPart), '</g>', '<g>\n', path, '</g>\n');
    string memory svgPart = string(SVG.group(body).id(tag).svg());
    output = string(SVG.document('0 0 1024 1024', bytes(svgPart), SVG.use(tag).svg()));
  }

  function isAssetRegistered(string memory assetName) public view returns (bool) {
    return assets[assetName] != IAssetProvider(address(0));
  }

}

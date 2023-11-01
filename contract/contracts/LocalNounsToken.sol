// SPDX-License-Identifier: MIT

/*
 * Created by @eiba8884
 */

pragma solidity ^0.8.6;

import '@openzeppelin/contracts/utils/Strings.sol';
import './libs/ProviderTokenA2.sol';
import { INounsSeeder } from './localNouns/interfaces/INounsSeeder.sol';
import './localNouns/interfaces/IAssetProviderExMint.sol';
import './localNouns/interfaces/ILocalNounsToken.sol';

contract LocalNounsToken is ProviderTokenA2, ILocalNounsToken {
  using Strings for uint256;

  IAssetProviderExMint public assetProvider2;
  address public minter;
  mapping(uint256 => uint256[]) public tradePrefecture; // トレード先指定の都道府県

  address public administratorsAddress; // 運営ウォレット
  address public developpersAddress; // 開発者ウォレット

  constructor(
    IAssetProviderExMint _assetProvider,
    address _minter
  ) ProviderTokenA2(_assetProvider, 'Local Nouns', 'Local Nouns') {
    description = 'Local Nouns Token.';
    assetProvider2 = _assetProvider;
    // mintPrice = 1e13; // 0.001   ※ mintPriceは Minterコントラクトで制御するため使用しない
    // mintLimit = 5000;            ※ mintLimitは Minterコントラクトで制御するため使用しない
    minter = _minter;
    administratorsAddress = msg.sender;
    developpersAddress = msg.sender;
  }

  function tokenName(uint256 _tokenId) internal pure override returns (string memory) {
    return string(abi.encodePacked('Local Nouns ', _tokenId.toString()));
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_tokenId < _nextTokenId(), 'LocalNounsToken.tokenURI: nonexistent token');

    (string memory svgPart, string memory tag) = assetProvider2.generateSVGPart(_tokenId);
    bytes memory image = bytes(svgPart);

    return
      string(
        abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name":"',
                tokenName(_tokenId),
                '","description":"',
                description,
                '","attributes":[',
                generateTraits(_tokenId),
                '],"image":"data:image/svg+xml;base64,',
                image,
                '"}'
              )
            )
          )
        )
      );
  }

  /**
   都道府県番号を指定してミントします。
   都道府県番号の下2桁=0を指定すると都道府県がランダムで選択されます。
   都道府県番号の下3桁目以降はバージョン番号です。
   ミント価格、ミント上限数は、Minterコントラクト側で制御するため、継承元のmintPrice, mintLimitは使用しません。
   */
  function mintSelectedPrefecture(
    address _to,
    uint256 _prefectureId,
    uint256 _amount
  ) public virtual returns (uint256 tokenId) {
    require(msg.sender == minter || msg.sender == owner(), 'Sender is not minter nor owner');
    require(_prefectureId % 100 <= 47, 'Invalid prefectureId');

    for (uint256 i = 0; i < _amount; i++) {
      assetProvider2.mint(_prefectureId, _nextTokenId() + i);
    }
    _safeMint(_to, _amount);
    return _nextTokenId() - 1;
  }

  function ownerMint(
    address[] memory _to,
    uint256[] memory _prefectureId,
    uint256[] memory _amount
  ) public onlyOwner returns (uint256 tokenId) {
    // 引数の整合性チェック
    require(_to.length == _prefectureId.length && _to.length == _amount.length, 'Invalid Arrays length');

    for (uint256 i; i < _to.length; i++) {
      mintSelectedPrefecture(_to[i], _prefectureId[i], _amount[i]);
    }
    return _nextTokenId() - 1;
  }

  function mint() public payable override returns (uint256 tokenId) {
    revert('Cannot use this function');
  }

  function setMinter(address _minter) public onlyOwner {
    minter = _minter;
  }

  function setAdministratorsAddress(address _admin) external onlyOwner {
    administratorsAddress = _admin;
  }

  function setDeveloppersAddress(address _developper) external onlyOwner {
    developpersAddress = _developper;
  }

  /**
   * @param _tokenId the token id for put on the trade list.
   * @param _prefectures prefectures that you want to trade. if you don't want specific prefecture, you don't need to set.
   */
  function putTradeLocalNoun(uint256 _tokenId, uint256[] memory _prefectures) public {
    for (uint256 i = 0; i < _prefectures.length; i++) {
      require(_prefectures[i] > 0 && _prefectures[i] <= 47, 'incorrect prefecutre id');
    }

    super.putTrade(_tokenId, true);
    tradePrefecture[_tokenId] = _prefectures;

    emit PutTradePrefecture(_tokenId, _prefectures);
  }

  function getTradePrefectureFor(uint256 _tokenId) public view returns (uint256[] memory) {
    return tradePrefecture[_tokenId];
  }

  function cancelTradeLocalNoun(uint256 _tokenId) public {
    super.putTrade(_tokenId, false);

    uint256[] memory emptyArray;
    tradePrefecture[_tokenId] = emptyArray;

    emit CancelTradePrefecture(_tokenId);
  }

  function executeTradeLocalNoun(uint256 _myTokenId, uint256 _targetTokenId) public {
    // tradePrefectureがない場合は、希望都道府県がないためチェック不要
    if (tradePrefecture[_targetTokenId].length > 0) {
      uint256 myTokenIdPrefecture = assetProvider2.getPrefectureId(_myTokenId);
      bool isIncludesList = false;
      for (uint256 i = 0; i < tradePrefecture[_targetTokenId].length; i++) {
        if (myTokenIdPrefecture == tradePrefecture[_targetTokenId][i]) {
          isIncludesList = true;
          break;
        }
      }
      require(isIncludesList, 'unmatch to the wants list');
    }

    super.executeTrade(_myTokenId, _targetTokenId);
  }

  function putTrade(uint256 _tokenId, bool _isOnTrade) public override {
    revert('Cannot use this function');
  }

  function executeTrade(uint256 _myTokenId, uint256 _targetTokenId) public override {
    revert('Cannot use this function');
  }

  // transfer時はトレード解除
  function _beforeTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity) internal override {
    uint256[] memory emptyArray;
    tradePrefecture[startTokenId] = emptyArray;
    super._beforeTokenTransfers(from, to, startTokenId, quantity);
  }

  // pay royalties to admin here
  function _processRoyalty(uint _salesPrice, uint _tokenId) internal override returns (uint256 royalty) {
    royalty = (_salesPrice * 100) / 1000; // 10.0%

    (bool sent, ) = payable(administratorsAddress).call{ value: royalty/2 }('');
    require(sent, 'failed to move fund to administratorsAddress contract');

    (bool sent2, ) = payable(developpersAddress).call{ value: royalty/2 }('');
    require(sent2, 'failed to move fund to developpersAddress contract');

  }

  function withdraw() external payable onlyOwner {
    require(administratorsAddress != address(0), "administratorsAddress shouldn't be 0");
    (bool sent, ) = payable(administratorsAddress).call{ value: address(this).balance }('');
    require(sent, 'failed to move fund to administratorsAddress contract');
  }

  // iLocalNounsTokenでERC721のtotalSupplyを使用したいけど、二重継承でエラーになるので個別関数を準備
  function totalSupply2() public view returns (uint256) {
    return super.totalSupply();
  }
}

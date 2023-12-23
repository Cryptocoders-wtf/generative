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
  mapping(uint256 => address) public tradeAddress; // トレード先指定のアドレス

  address[] public royaltyAddresses; // ロイヤリティ送信先ウォレット
  mapping(address => uint256) public royaltyRatio; // ロイヤリティ送信先ウォレットごとの割合
  uint256 royaltyRatioTotal; // royaltyRatioの合計(割戻用)
  bool public canSetApproval = false; // setApprovalForAll, approveの可否

  uint256 public tradeRoyalty = 0.003 ether; // P2Pトレードのロイヤリティ
  uint256 public salesRoyaltyBasisPoint = 1000; // P2Pセールのロイヤリティ、購入価格の10%

  mapping(address => bool) public approveWhiteList; // Approveを許可するアドレスリスト

  constructor(
    IAssetProviderExMint _assetProvider,
    address _minter
  ) ProviderTokenA2(_assetProvider, 'Local Nouns', 'Local Nouns') {
    description = 'Local Nouns';
    assetProvider2 = _assetProvider;
    minter = _minter;

    // ロイヤリティ送信先(コンストラクタではデプロイアドレス100%)
    royaltyAddresses = [msg.sender];
    royaltyRatio[msg.sender] = 1;
    royaltyRatioTotal = 1;
  }

  function tokenName(uint256 _tokenId) internal pure override returns (string memory) {
    return string(abi.encodePacked('Local Nouns ', _tokenId.toString()));
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_tokenId < _nextTokenId(), 'nonexistent token');

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
    require(msg.sender == minter || msg.sender == owner(), 'Invalid sender');
    require(_prefectureId % 100 <= 47, 'Invalid prefectureId');

    // リエントランシー対策のため状態変更を先に実施
    _safeMint(_to, _amount);

    uint256 startTokenId = _nextTokenId() - _amount;

    for (uint256 i = 0; i < _amount; i++) {
      assetProvider2.mint(_prefectureId, startTokenId + i);
    }
    return _nextTokenId() - 1;
  }

  function ownerMint(
    address[] memory _to,
    uint256[] memory _prefectureId,
    uint256[] memory _amount
  ) external onlyOwner returns (uint256 tokenId) {
    // 引数の整合性チェック
    require(_to.length == _prefectureId.length && _to.length == _amount.length, 'Invalid Arrays length');

    for (uint256 i; i < _to.length; i++) {
      mintSelectedPrefecture(_to[i], _prefectureId[i], _amount[i]);
    }
    return _nextTokenId() - 1;
  }

  function mint() public payable override returns (uint256) {
    revert('Cannot use');
  }

  function setMinter(address _minter) external onlyOwner {
    minter = _minter;
  }

  function setCanSetAproval(bool _canSetApproval) external onlyOwner {
    canSetApproval = _canSetApproval;
  }

  function setApproveWhiteList(address _address, bool approve) external onlyOwner {
    approveWhiteList[_address] = approve;
  }

  function setRoyaltyAddresses(address[] memory _addr, uint256[] memory ratio) external onlyOwner {
    // 引数の整合性チェック
    require(_addr.length == ratio.length, 'Invalid Arrays length');
    royaltyAddresses = _addr;
    royaltyRatioTotal = 0;

    for (uint256 i = 0; i < _addr.length; i++) {
      royaltyRatio[_addr[i]] = ratio[i];
      royaltyRatioTotal += ratio[i];
    }
  }

  /**
   * @param _tokenId the token id for put on the trade list.
   * @param _prefectures prefectures that you want to trade. if you don't want specific prefecture, you don't need to set.
   * @param _tradeAddress the address only who can trade.
   */
  function putTradeLocalNoun(uint256 _tokenId, uint256[] memory _prefectures, address _tradeAddress) public {
    for (uint256 i = 0; i < _prefectures.length; i++) {
      require(_prefectures[i] > 0 && _prefectures[i] <= 47, 'incorrect prefecutre id');
    }

    super.putTrade(_tokenId, true);
    tradePrefecture[_tokenId] = _prefectures;
    if (_tradeAddress != address(0)) {
      tradeAddress[_tokenId] = _tradeAddress;
    }

    emit PutTradePrefecture(_tokenId, _prefectures, _tradeAddress);
  }

  function getTradePrefectureFor(uint256 _tokenId) public view returns (uint256[] memory) {
    return tradePrefecture[_tokenId];
  }

  function cancelTradeLocalNoun(uint256 _tokenId) public {
    super.putTrade(_tokenId, false);

    uint256[] memory emptyArray;
    tradePrefecture[_tokenId] = emptyArray;
    tradeAddress[_tokenId] = address(0);

    emit CancelTradePrefecture(_tokenId);
  }

  function executeTradeLocalNoun(uint256 _myTokenId, uint256 _targetTokenId) public payable {
    require(msg.value >= tradeRoyalty, 'Insufficial royalty');

    // tradeAddressがある場合はmsg.senderをチェック
    require(
      tradeAddress[_targetTokenId] == address(0) || msg.sender == tradeAddress[_targetTokenId],
      'Limited address can trade'
    );

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
    _processTradeRoyalty(msg.value);
    emit ExecuteTrade(_targetTokenId, ownerOf(_targetTokenId), _myTokenId, ownerOf(_myTokenId));
  }

  function putTrade(uint256, bool) public pure override {
    revert('Cannot use');
  }

  function executeTrade(uint256, uint256) public pure override {
    revert('Cannot use');
  }

  function purchase(uint256 _tokenId, address _buyer, address _facilitator) external payable override {
    super._purchase(_tokenId, _buyer, _facilitator);
    emit Purchase(_tokenId, _buyer);
  }

  // transfer時はトレード解除
  function _beforeTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity) internal override {
    uint256[] memory emptyArray;
    tradePrefecture[startTokenId] = emptyArray;
    tradeAddress[startTokenId] = address(0);
    super._beforeTokenTransfers(from, to, startTokenId, quantity);
  }

  function setTradeRoyalty(uint256 _royalty) external onlyOwner {
    tradeRoyalty = _royalty;
  }

  function setSalesRoyaltyBasisPoint(uint256 _bp) external onlyOwner {
    salesRoyaltyBasisPoint = _bp;
  }

  // pay royalties to admin here
  function _processRoyalty(uint _salesPrice, uint) internal override returns (uint256 royalty) {
    // royalty = (_salesPrice * 100) / 1000; // 10.0%
    royalty = (_salesPrice * salesRoyaltyBasisPoint) / 10000;
    _sendRoyalty(royalty);
  }

  // pay royalties to admin here
  function _processTradeRoyalty(uint _royalty) internal {
    _sendRoyalty(_royalty);
  }

  // send royalties to admin and developper
  function _sendRoyalty(uint _royalty) internal {
    for (uint256 i = 0; i < royaltyAddresses.length; i++) {
      _trySendRoyalty(royaltyAddresses[i], (_royalty * royaltyRatio[royaltyAddresses[i]]) / royaltyRatioTotal);
    }
  }

  function _trySendRoyalty(address to, uint amount) internal {
    (bool sent, ) = payable(to).call{ value: amount }('');
    require(sent, 'Failed to send');
  }

  function withdraw() external payable onlyOwner {
    _sendRoyalty(address(this).balance);
  }

  // 二重継承でエラーになるので個別関数を準備
  function totalSupply2() public view returns (uint256) {
    return super.totalSupply();
  }

  // 誰もがトークンを承認できないようにする
  function setApprovalForAll(address operator, bool approved) public override {
    require(canSetApproval || approveWhiteList[operator], 'Not allowed to set approval for all');
    super.setApprovalForAll(operator, approved);
  }

  // 特定のトークンの承認も不可能にする
  function approve(address to, uint256 tokenId) public payable override {
    require(canSetApproval || approveWhiteList[to], 'Not allowed to approve');
    super.approve(to, tokenId);
  }
}

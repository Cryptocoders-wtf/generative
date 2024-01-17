import { expect } from 'chai';
import { ethers, network, SignerWithAddress, Contract } from "hardhat";
import { addresses } from '../../src/utils/addresses';
import { ethers } from 'ethers';
import { abi as sampleTokenAbi } from "../artifacts/contracts/sampleToken.sol/sampleToken";

let owner: SignerWithAddress, user1: SignerWithAddress, user2: SignerWithAddress, user3: SignerWithAddress, user4: SignerWithAddress, user5: SignerWithAddress, admin: SignerWithAddress, developper: SignerWithAddress;
let token: Contract, minter: Contract, provider: Contract, tokenGate: Contract, sampleToken: Contract;

const nounsDescriptorAddress = addresses.nounsDescriptor[network.name];
const localNounsDescriptorAddress = addresses.localNounsDescriptor[network.name];
const nounsSeederAddress = addresses.nounsSeeder[network.name];
const localSeederAddress = addresses.localSeeder[network.name];
const sampleTokenAddress = addresses.sampleToken[network.name];

const zeroAddress = '0x0000000000000000000000000000000000000000';

before(async () => {
    /* `npx hardhat node`実行後、このスクリプトを実行する前に、Nouns,LocalNounsの関連するコントラクトを
     * デプロイする必要があります。(一度実行すると、node停止までは再実施する必要なし)
        # cd contract
         npx hardhat run scripts/deploy_nounsDescriptorV1.ts
         npx hardhat run scripts/populate_nounsV1.ts
         npx hardhat run scripts/deploy_localNouns.ts
         npx hardhat run scripts/populate_localNouns.ts
         npx hardhat run scripts/deploy_sample.ts

        note: `npx hardhat node`実行時にJavaScript heap out of memory が発生した場合は環境変数で使用メモリを指定する
        export NODE_OPTIONS=--max-old-space-size=4096

        # テスト実行
        # npx hardhat test test/localNounsMinter2.ts

     */

    [owner, user1, user2, user3, user4, user5, admin, developper] = await ethers.getSigners();

    const factoryTokenGate = await ethers.getContractFactory('AssetTokenGate');
    tokenGate = await factoryTokenGate.deploy();
    await tokenGate.deployed();

    const factoryProvider = await ethers.getContractFactory('LocalNounsProvider2');
    provider = await factoryProvider.deploy(
        nounsDescriptorAddress, localNounsDescriptorAddress);
    await provider.deployed();
    // console.log(`##LocalNounsProvider="${provider.address}"`);

    const factoryToken = await ethers.getContractFactory('LocalNounsToken');
    token = await factoryToken.deploy(provider.address, owner.address);
    await token.deployed();
    // console.log(`##LocalNounsToken="${token.address}"`);

    const factoryMinter = await ethers.getContractFactory('LocalNounsMinter2');
    minter = await factoryMinter.deploy(token.address, tokenGate.address);
    await minter.deployed();
    // console.log(`##LocalNounsMinter="${minter.address}"`);

    await token.setMinter(minter.address);

    // sampleTokenのコントラクト定義
    sampleToken = await ethers.getContractAt(sampleTokenAbi, sampleTokenAddress);

    // tokenGateにsampleTokenをセット
    await tokenGate.setWhitelist([sampleToken.address]);

});

describe('mint functions', function () {
    let result, tx;

    it('mint from non-minter', async function () {
        await expect(token.connect(user1).functions.mint())
            .revertedWith('Cannot use');

        await expect(token.connect(user1).functions.mintSelectedPrefecture(user1.address, 1, 1))
            .revertedWith('Invalid sender');

        await expect(token.connect(user1).functions.ownerMint([user1.address], [1], [1]))
            .revertedWith('Ownable: caller is not the owner');

    });

    it('mint at lock phaze', async function () {

        const [phaze] = await minter.functions.phase();
        expect(phaze).to.equal(2); // PublicSale

        await minter.connect(owner).functions.setPhase(0);
        const [phaze2] = await minter.functions.phase();
        expect(phaze2).to.equal(0); // PublicSale

        await expect(minter.connect(user1).functions.mintSelectedPrefecture(1, 1))
            .revertedWith('Sale is locked');

        await minter.connect(owner).functions.setPhase(2);
        const [phaze3] = await minter.functions.phase();
        expect(phaze3).to.equal(2); // PublicSale

    });

    it('Invalid prefectureId', async function () {

        // OKパターンは別テストで実施
        const txParams = { value: ethers.utils.parseUnits("0.03", "ether") };
        await expect(minter.connect(user4).functions.mintSelectedPrefecture(48, 1, txParams))
            .revertedWith('Invalid prefectureId');
    });

    it('mint from minter', async function () {

        const txParams = { value: ethers.utils.parseUnits("0.01", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(0, 1, txParams);

        const [balance] = await token.functions.balanceOf(user1.address);
        expect(balance.toNumber()).to.equal(1); // user1は1つ保持

        const [owner0] = await token.functions.ownerOf(0);
        expect(owner0).to.equal(user1.address);

        const [totalSupply] = await token.functions.totalSupply();
        expect(totalSupply.toNumber()).to.equal(1); // tokenId=1

        const [traits1] = await provider.functions.generateTraits(0);
        // console.log('mint from minter', traits1);

    });

    it('mint from minter2', async function () {

        const txParams = { value: ethers.utils.parseUnits("0.01", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture2(0, 1, user2.address, txParams);

        const [balance] = await token.functions.balanceOf(user2.address);
        expect(balance.toNumber()).to.equal(1); // user2は1つ保持

        const [owner1] = await token.functions.ownerOf(1);
        expect(owner1).to.equal(user2.address);

        const [totalSupply] = await token.functions.totalSupply();
        expect(totalSupply.toNumber()).to.equal(2); // tokenId=1

        const [traits1] = await provider.functions.generateTraits(1);
        // console.log('mint from minter', traits1);

    });

    it('multiple mint', async function () {

        const [balance0] = await token.functions.balanceOf(user3.address);

        const txParams = { value: ethers.utils.parseUnits("0.09", "ether") };
        await minter.connect(user3).functions.mintSelectedPrefecture(16, 3, txParams);

        const [balance] = await token.functions.balanceOf(user3.address);

        expect(balance.toNumber()).to.equal(3); // user3は3つ追加

        const [owner0] = await token.functions.ownerOf(2);
        expect(owner0).to.equal(user3.address);

        const [owner1] = await token.functions.ownerOf(3);
        expect(owner1).to.equal(user3.address);

        const [owner2] = await token.functions.ownerOf(4);
        expect(owner2).to.equal(user3.address);

        const [totalSupply] = await token.functions.totalSupply();
        expect(totalSupply.toNumber()).to.equal(5); // tokenId=1

        // Traitsに指定した都道府県名が設定される
        const [traits1] = await provider.functions.generateTraits(2);
        const [traits2] = await provider.functions.generateTraits(3);
        const [traits3] = await provider.functions.generateTraits(4);
        // head,accessoryがランダムなので県のみチェック(head,accessoryは目視)
        console.log('multiple mint', traits1);
        console.log('multiple mint', traits2);
        console.log('multiple mint', traits3);
        expect(traits1.includes('{"trait_type": "prefecture" , "value":"Toyama"}')).to.equal(true);
        expect(traits2.includes('{"trait_type": "prefecture" , "value":"Toyama"}')).to.equal(true);
        expect(traits3.includes('{"trait_type": "prefecture" , "value":"Toyama"}')).to.equal(true);

        // 都道府県ごとのミント数
        const [mintNumberPerPrefecture] = await provider.functions.mintNumberPerPrefecture(16);
        expect(mintNumberPerPrefecture.toNumber()).to.equal(3); // tokenId=1

    });

    it('owner mint', async function () {

        const [balance3] = await token.functions.balanceOf(user3.address);
        const [balance4] = await token.functions.balanceOf(user4.address);
        const [balance5] = await token.functions.balanceOf(user5.address);
        const [totalSupply] = await token.functions.totalSupply();

        const txParams = { value: 0 };
        await token.connect(owner).functions.ownerMint([user3.address, user4.address, user5.address], [3, 5, 0], [1, 2, 20], txParams);

        const [balance3a] = await token.functions.balanceOf(user3.address);
        const [balance4a] = await token.functions.balanceOf(user4.address);
        const [balance5a] = await token.functions.balanceOf(user5.address);

        expect(balance3a.toNumber()).to.equal(balance3.toNumber() + 1);
        expect(balance4a.toNumber()).to.equal(balance4.toNumber() + 2);
        expect(balance5a.toNumber()).to.equal(balance5.toNumber() + 20);

        const [totalSupplya] = await token.functions.totalSupply();
        expect(totalSupplya.toNumber()).to.equal(totalSupply.toNumber() + 23);

    });

    it('tokenGate', async function () {

        await minter.connect(owner).functions.setPhase(1);
        const [phaze] = await minter.functions.phase();
        expect(phaze).to.equal(1); // PreSale

        const txParams = { value: ethers.utils.parseUnits("0.09", "ether") };
        // この後でSampleTokenをmintするので、node起動後の1回目しか正常に動作しない
        await expect(minter.connect(user4).functions.mintSelectedPrefecture(1, 1, txParams))
            .revertedWith('TokenGate token is needed');

        // sampleTokenをミント 
        await sampleToken.connect(user4).functions.mint();

        const [balance] = await token.functions.balanceOf(user4.address);
        await minter.connect(user4).functions.mintSelectedPrefecture(1, 3, txParams);

        const [balance2] = await token.functions.balanceOf(user4.address);

        expect(balance2.toNumber() - balance.toNumber()).to.equal(3); // user4は3つ追加

        await minter.connect(owner).functions.setPhase(2);
        const [phaze2] = await minter.functions.phase();
        expect(phaze2).to.equal(2); // PublicSale

    });

    it('Send eth', async function () {

        await minter.connect(owner).functions.setPhase(2);
        const [phaze] = await minter.functions.phase();
        expect(phaze).to.equal(2); // PreSale

        // 都道府県指定 OKパターンは'multiple mint'テストで実施
        const txParams = { value: ethers.utils.parseUnits("0.059", "ether") };
        await expect(minter.connect(user4).functions.mintSelectedPrefecture(1, 2, txParams))
            .revertedWith('Must send the mint price');

        // 都道府県指定なし OKパターンは'mint from minter'テストで実施
        const txParams2 = { value: ethers.utils.parseUnits("0.019", "ether") };
        await expect(minter.connect(user4).functions.mintSelectedPrefecture(0, 2, txParams2))
            .revertedWith('Must send the mint price');

    });

});

describe('determinePrefectureId', function () {
    it.skip('determinePrefectureId', async function () {

        let prefectureCount = new Array(47).fill(0);

        for (var i = 0; i < 1500; i++) {
            const [prefectureId] = await provider.connect(owner).functions.determinePrefectureId(i);
            prefectureCount[prefectureId.toNumber() - 1]++;
        }

        // 全ての都道府県が１以上出現する
        for (var i = 0; i < prefectureCount.length; i++) {
            expect(prefectureCount[i]).to.greaterThan(0);
            console.log("prefectureId", i+1, prefectureCount[i], prefectureCount[i]/1500*100 + '%');
        }

    });

    it('mint all prefecture', async function () {

        await minter.connect(owner).functions.setPhase(2);
        const txParams = { value: ethers.utils.parseUnits("0.3", "ether") };

        // 全ての都道府県が１以上出現する
        for (var i = 0; i < 47; i++) {
            // ミント前の都道府県ごとのカウント
            const [mintNumberPerPrefecture] = await provider.functions.mintNumberPerPrefecture(i + 1);

            // console.log("mint all prefecture", i + 1);
            await minter.connect(user1).functions.mintSelectedPrefecture(i + 1, 5, txParams);

            // ミント後の都道府県ごとのカウント
            const [mintNumberPerPrefecture2] = await provider.functions.mintNumberPerPrefecture(i + 1);

            expect(mintNumberPerPrefecture2.sub(mintNumberPerPrefecture).toNumber(), "prefectureId:" + (i + 1)).to.equal(5);
        }

    }).timeout(600000); // タイムアウトを60秒に設定
});

describe('P2P', function () {
    let tx, result, tokenId1: number;
    const price = ethers.BigNumber.from('1000000000000000');

    it('not on sale', async function () {

        const txParams = { value: ethers.utils.parseUnits("0.03", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(10, 1, txParams);
        result = await token.totalSupply();
        tokenId1 = result.toNumber() - 1;

        // セールなし
        await expect(token.connect(user2).purchase(tokenId1, user2.address, zeroAddress)).revertedWith('Token is not on sale');
    });

    it('Over the mint limit', async function () {

        // mintMaxに現在の発行数+1をセット
        const [totalSupply] = await token.functions.totalSupply();
        await minter.functions.setMintMax(totalSupply.toNumber() + 1);
        const [mintMax] = await minter.functions.mintMax();
        expect(mintMax.toNumber()).to.equal(totalSupply.toNumber() + 1);

        const txParams = { value: ethers.utils.parseUnits("0.06", "ether") };
        await expect(minter.connect(user5).functions.mintSelectedPrefecture(47, 2, txParams))
            .revertedWith('Over the mint limit');

        // 一つだけならOK
        const [balance] = await token.functions.balanceOf(user5.address);
        const txParams2 = { value: ethers.utils.parseUnits("0.03", "ether") };
        await minter.connect(user5).functions.mintSelectedPrefecture(47, 1, txParams2);

        const [balancea] = await token.functions.balanceOf(user5.address);
        expect(balancea.toNumber()).to.equal(balance.toNumber() + 1); // user1は1つ保持

        await minter.functions.setMintMax(1500);
        const [mintMax2] = await minter.functions.mintMax();
        expect(mintMax2.toNumber()).to.equal(1500);
    });

    it('SetPrice', async function () {
        await expect(token.connect(user2).setPriceOf(tokenId1, price)).revertedWith('Only the onwer can set the price');
        await token.connect(user1).setPriceOf(tokenId1, price);
        result = await token.getPriceOf(tokenId1);
        expect(result.toNumber()).equal(price);

        await expect(token.connect(user2).purchase(tokenId1, user2.address, zeroAddress)).revertedWith('Not enough fund');

    });

    it('Purchase', async function () {
        await expect(token.connect(user2).purchase(tokenId1, user2.address, zeroAddress)).revertedWith('Not enough fund');

        // await token.connect(owner).setAdministratorsAddress(admin.address);
        // await token.connect(owner).setDeveloppersAddress(developper.address);
        await token.connect(owner).setRoyaltyAddresses([developper.address,admin.address],[3,1]);

        result = await token.ownerOf(tokenId1);

        const balance1 = await ethers.provider.getBalance(user1.address);
        const balanceA = await ethers.provider.getBalance(admin.address);
        const balanceD = await ethers.provider.getBalance(developper.address);

        await token.connect(user2).purchase(tokenId1, user2.address, zeroAddress, { value: price });
        result = await token.ownerOf(tokenId1);
        expect(result).equal(user2.address);

        const balance12 = await ethers.provider.getBalance(user1.address);
        expect(balance12.sub(balance1)).equal(price.div(40).mul(36)); // 90%
        const balanceA2 = await ethers.provider.getBalance(admin.address);
        expect(balanceA2.sub(balanceA)).equal(price.div(40).mul(1)); // 5%
        const balanceD2 = await ethers.provider.getBalance(developper.address);
        expect(balanceD2.sub(balanceD)).equal(price.div(40).mul(3)); // 15%

    });

    it('Attempt to setprice/buy by user1', async function () {
        await expect(token.connect(user1).purchase(0, user2.address, zeroAddress, { value: price })).revertedWith('Token is not on sale');
        await expect(token.connect(user1).setPriceOf(tokenId1, price)).revertedWith('Only the onwer can set the price');
    });
});

describe('P2PTradable', function () {
    let result, tx, err, balance, tokenId1: number, tokenId2: number;
    const txParams = { value: ethers.utils.parseUnits("0.003", "ether") };

    it('mint for test', async function () {
        // for user1
        const txParams = { value: ethers.utils.parseUnits("0.03", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(5, 1, txParams);
        result = await token.totalSupply();
        tokenId1 = result.toNumber() - 1;

        // for user2
        await minter.connect(user2).functions.mintSelectedPrefecture(10, 1, txParams);
        result = await token.totalSupply();
        tokenId2 = result.toNumber() - 1;

    });

    it('Attempt to super functions', async function () {
        await expect(token.connect(user2).executeTrade(tokenId2, tokenId1)).revertedWith('Cannot use');

        await expect(token.connect(user2).putTrade(tokenId1, true)).revertedWith('Cannot use');

    });

    it('Attempt to trade non-tradable token', async function () {
        await expect(token.connect(user2).executeTradeLocalNoun(tokenId2, tokenId1, txParams)).revertedWith('TargetTokenId is not on trade');
    });

    it('Attempt to execute trade non-owner token', async function () {
        await expect(token.connect(user2).executeTradeLocalNoun(tokenId1, tokenId2, txParams)).revertedWith('Only the onwer can trade');
    });

    it('Attempt to put trade non-owner token', async function () {
        await expect(token.connect(user2).putTradeLocalNoun(tokenId1, [], zeroAddress)).revertedWith('Only the onwer can trade');
    });

    it('incorrect prefecutre id', async function () {
        await expect(token.connect(user2).putTradeLocalNoun(tokenId1, [0], zeroAddress)).revertedWith('incorrect prefecutre id');
        await expect(token.connect(user2).putTradeLocalNoun(tokenId1, [48], zeroAddress)).revertedWith('incorrect prefecutre id');
    });

    it('put trade', async function () {
        
        await token.connect(owner).setRoyaltyAddresses([developper.address,admin.address],[1,1]);

        // 希望都道府県外のトークンと交換しようとする
        await token.connect(user1).putTradeLocalNoun(tokenId1, [1, 11, 12], zeroAddress);
        await expect(token.connect(user2).executeTradeLocalNoun(tokenId2, tokenId1, txParams)).revertedWith('unmatch to the wants list');

        result = await token.connect(user1).getTradePrefectureFor(tokenId1);
        expect(result.length).equal(3);
        expect(result[0].toNumber()).equal(1);
        expect(result[1].toNumber()).equal(11);
        expect(result[2].toNumber()).equal(12);

        await token.connect(user1).putTradeLocalNoun(tokenId1, [10, 11, 12], zeroAddress);
        result = await token.connect(user1).trades(tokenId1);
        expect(result).equal(true);

        // 実行前の保持ETH
        const balanceA = await ethers.provider.getBalance(admin.address);
        const balanceD = await ethers.provider.getBalance(developper.address);

        const txParams2 = { value: ethers.utils.parseUnits("0.0029", "ether") };
        await expect(token.connect(user2).executeTradeLocalNoun(tokenId2, tokenId1, txParams2)).revertedWith('Insufficial royalty');

        tx = await token.connect(user2).executeTradeLocalNoun(tokenId2, tokenId1, txParams);
        await tx.wait();
        result = await token.connect(user1).trades(tokenId1);
        expect(result).equal(false);  //トレードリストから解除

        result = await token.connect(user1).ownerOf(tokenId1);
        expect(result).equal(user2.address);

        result = await token.connect(user1).ownerOf(tokenId2);
        expect(result).equal(user1.address);

        // 実行後の保持ETH
        const balanceA2 = await ethers.provider.getBalance(admin.address);
        const balanceD2 = await ethers.provider.getBalance(developper.address);
        expect(balanceA2.sub(balanceA)).to.equal(ethers.utils.parseUnits("0.0015", "ether"));
        expect(balanceD2.sub(balanceD)).to.equal(ethers.utils.parseUnits("0.0015", "ether"));

    });

    it('put trade(都道府県指定なし)', async function () {
        // for user1
        const txParams = { value: ethers.utils.parseUnits("0.03", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(10, 1, txParams);
        result = await token.totalSupply();
        tokenId1 = result.toNumber() - 1;

        // for user2
        await minter.connect(user2).functions.mintSelectedPrefecture(10, 1, txParams);
        result = await token.totalSupply();
        tokenId2 = result.toNumber() - 1;

        // 希望都道府県なしでトレードリストに出す
        await token.connect(user1).putTradeLocalNoun(tokenId1, [], zeroAddress);

        result = await token.connect(user1).trades(tokenId1);
        expect(result).equal(true);

        result = await token.connect(user1).getTradePrefectureFor(tokenId1);
        expect(result.length).equal(0);

        tx = await token.connect(user2).executeTradeLocalNoun(tokenId2, tokenId1, txParams);
        await tx.wait();
        result = await token.connect(user1).trades(tokenId1);
        expect(result).equal(false);  //トレードリストから解除

        result = await token.connect(user1).ownerOf(tokenId1);
        expect(result).equal(user2.address);

        result = await token.connect(user1).ownerOf(tokenId2);
        expect(result).equal(user1.address);
    });

    it('put trade(トレード先アドレス指定)', async function () {
        // for user1
        const txParams = { value: ethers.utils.parseUnits("0.03", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(10, 1, txParams);
        result = await token.totalSupply();
        tokenId1 = result.toNumber() - 1;

        // for user2
        await minter.connect(user2).functions.mintSelectedPrefecture(10, 1, txParams);
        result = await token.totalSupply();
        tokenId2 = result.toNumber() - 1;

        // ユーザ2のアドレス指定でトレードリストに出す
        await token.connect(user1).putTradeLocalNoun(tokenId1, [], user2.address);

        result = await token.connect(user1).trades(tokenId1);
        expect(result).equal(true);

        result = await token.connect(user1).tradeAddress(tokenId1);
        expect(result).equal(user2.address);

        // ユーザ3がトレードしようとする　→ 失敗
        await expect(token.connect(user3).executeTradeLocalNoun(tokenId2, tokenId1, txParams)).revertedWith('Limited address can trade');

        // ユーザ2がトレードしようとする　→ 成功
        tx = await token.connect(user2).executeTradeLocalNoun(tokenId2, tokenId1, txParams);
        await tx.wait();
        result = await token.connect(user1).trades(tokenId1);
        expect(result).equal(false);  //トレードリストから解除

        result = await token.connect(user1).ownerOf(tokenId1);
        expect(result).equal(user2.address);

        result = await token.connect(user1).ownerOf(tokenId2);
        expect(result).equal(user1.address);
    });

    it('cancel trade', async function () {
        // for user1
        const txParams = { value: ethers.utils.parseUnits("0.03", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(10, 1, txParams);
        result = await token.totalSupply();
        tokenId1 = result.toNumber() - 1;

        // for user2
        await minter.connect(user2).functions.mintSelectedPrefecture(10, 1, txParams);
        result = await token.totalSupply();
        tokenId2 = result.toNumber() - 1;

        // 希望都道府県なしでトレードリストに出す
        await token.connect(user1).putTradeLocalNoun(tokenId1, [], zeroAddress);

        result = await token.connect(user1).trades(tokenId1);
        expect(result).equal(true);

        // オーなー以外がキャンセルしようとする
        await expect(token.connect(user2).cancelTradeLocalNoun(tokenId1)).revertedWith('Only the onwer can trade');

        // オーなーがキャンセルする
        await token.connect(user1).cancelTradeLocalNoun(tokenId1);
        result = await token.connect(user1).trades(tokenId1);
        expect(result).equal(false);  //トレードリストから解除

        await expect(token.connect(user2).executeTradeLocalNoun(tokenId2, tokenId1, txParams)).revertedWith('TargetTokenId is not on trade');

    });

});


describe('Approval', function () {
    let result, tx, err, balance, tokenId1: number, tokenId2: number;
    const txParams = { value: ethers.utils.parseUnits("0.003", "ether") };

    it('Approvale error', async function () {
        await minter.connect(owner).functions.setPhase(2);
        // for user1
        const txParams = { value: ethers.utils.parseUnits("0.03", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(5, 1, txParams);
        result = await token.totalSupply();
        tokenId1 = result.toNumber() - 1;

        await expect(token.connect(user1).functions.setApprovalForAll(user2.address, true)).revertedWith('Not allowed to set approval for all');

        await expect(token.connect(user1).functions.approve(user2.address, tokenId1)).revertedWith('Not allowed to approve');
    });

    it('setApprovalForAll', async function () {
        await minter.connect(owner).functions.setPhase(2);
        // for user1
        const txParams = { value: ethers.utils.parseUnits("0.03", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(5, 1, txParams);
        result = await token.totalSupply();
        tokenId1 = result.toNumber() - 1;

        await token.connect(owner).functions.setCanSetAproval(true);

        await token.connect(user1).functions.setApprovalForAll(user2.address, true);

        result = await token.isApprovedForAll(user1.address, user2.address);

        expect(result).equal(true); 


    });

    it('setApprovalForAllWithWhiteList', async function () {
        await minter.connect(owner).functions.setPhase(2);
        // for user1
        const txParams = { value: ethers.utils.parseUnits("0.03", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(5, 1, txParams);
        result = await token.totalSupply();
        tokenId1 = result.toNumber() - 1;

        await token.connect(owner).functions.setCanSetAproval(false);
        await token.connect(owner).functions.setApproveWhiteList(user2.address, true);

        await token.connect(user1).functions.setApprovalForAll(user2.address, true);

        result = await token.isApprovedForAll(user1.address, user2.address);

        expect(result).equal(true); 
    });

    it('approve', async function () {
        await minter.connect(owner).functions.setPhase(2);
        // for user1
        const txParams = { value: ethers.utils.parseUnits("0.03", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(5, 1, txParams);
        result = await token.totalSupply();
        tokenId1 = result.toNumber() - 1;

        await token.connect(owner).functions.setCanSetAproval(true);

        await token.connect(user1).functions.approve(user2.address, tokenId1);

        result = await token.getApproved(tokenId1);

        expect(result).equal(user2.address); 


    });

    it('approveWithWhiteList', async function () {
        await minter.connect(owner).functions.setPhase(2);
        // for user1
        const txParams = { value: ethers.utils.parseUnits("0.03", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(5, 1, txParams);
        result = await token.totalSupply();
        tokenId1 = result.toNumber() - 1;

        await token.connect(owner).functions.setCanSetAproval(false);
        await token.connect(owner).functions.setApproveWhiteList(user2.address, true);

        await token.connect(user1).functions.approve(user2.address, tokenId1);

        result = await token.getApproved(tokenId1);

        expect(result).equal(user2.address); 
    });

});

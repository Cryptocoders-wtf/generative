import { expect } from 'chai';
import { ethers, network, SignerWithAddress, Contract } from "hardhat";
import { addresses } from '../../src/utils/addresses';
import { ethers } from 'ethers';
import { abi as sampleTokenAbi } from "../artifacts/contracts/sampleToken.sol/sampleToken";

let owner: SignerWithAddress, user1: SignerWithAddress, user2: SignerWithAddress, user3: SignerWithAddress, user4: SignerWithAddress, admin: SignerWithAddress;
let token: Contract, minter: Contract, provider: Contract, tokenGate: Contract, sampleToken: Contract;

const nounsDescriptorAddress = addresses.nounsDescriptor[network.name];
const localNounsDescriptorAddress = addresses.localNounsDescriptor[network.name];
const nounsSeederAddress = addresses.nounsSeeder[network.name];
const localSeederAddress = addresses.localSeeder[network.name];
const sampleTokenAddress = addresses.sampleToken[network.name];

before(async () => {
    /* `npx hardhat node`実行後、このスクリプトを実行する前に、Nouns,LocalNounsの関連するコントラクトを
     * デプロイする必要があります。(一度実行すると、node停止までは再実施する必要なし)
        # cd contract
        # npx hardhat run scripts/deploy_nounsDescriptorV1.ts
        # npx hardhat run scripts/populate_nounsV1.ts
        # npx hardhat run scripts/deploy_localNouns.ts
        # npx hardhat run scripts/populate_localNouns.ts
        # npx hardhat run scripts/deploy_sample.ts
     */

    [owner, user1, user2, user3, user4, admin] = await ethers.getSigners();

    const factoryTokenGate = await ethers.getContractFactory('AssetTokenGate');
    tokenGate = await factoryTokenGate.deploy();
    await tokenGate.deployed();

    const factoryProvider = await ethers.getContractFactory('LocalNounsProvider');
    provider = await factoryProvider.deploy(
        nounsDescriptorAddress, localNounsDescriptorAddress, nounsSeederAddress, localSeederAddress);
    await provider.deployed();
    // console.log(`##LocalNounsProvider="${provider.address}"`);

    const factoryToken = await ethers.getContractFactory('LocalNounsToken');
    token = await factoryToken.deploy(provider.address, owner.address);
    await token.deployed();
    // console.log(`##LocalNounsToken="${token.address}"`);

    const factoryMinter = await ethers.getContractFactory('LocalNounsMinter');
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
            .revertedWith('Cannot use this function');

        await expect(token.connect(user1).functions.mintSelectedPrefecture(user1.address, 1, 1))
            .revertedWith('Sender is not the minter');

    });

    it('mint at lock phaze', async function () {

        const [phaze] = await minter.functions.phase();
        expect(phaze).to.equal(0); // Lock

        await expect(minter.connect(user1).functions.mintSelectedPrefecture(1, 1))
            .revertedWith('Sale is locked');

        await minter.connect(owner).functions.setPhase(2);
        const [phaze2] = await minter.functions.phase();
        expect(phaze2).to.equal(2); // PublicSale

    });

    it('mint from minter', async function () {

        const txParams = { value: ethers.utils.parseUnits("0.001", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(0, 1,txParams);

        const [balance] = await token.functions.balanceOf(user1.address);
        expect(balance.toNumber()).to.equal(1); // user1は1つ保持

        const [owner0] = await token.functions.ownerOf(0);
        expect(owner0).to.equal(user1.address);

        const [totalSupply] = await token.functions.totalSupply();
        expect(totalSupply.toNumber()).to.equal(1); // tokenId=1

        const [traits1] = await provider.functions.generateTraits(0);
        console.log('mint from minter',traits1);

    });

    it('multiple mint', async function () {

        const [balance0] = await token.functions.balanceOf(user3.address);

        const txParams = { value: ethers.utils.parseUnits("0.009", "ether") };
        await minter.connect(user3).functions.mintSelectedPrefecture(16, 3, txParams);

        const [balance] = await token.functions.balanceOf(user3.address);

        expect(balance.toNumber()).to.equal(3); // user3は3つ追加

        const [owner0] = await token.functions.ownerOf(1);
        expect(owner0).to.equal(user3.address);

        const [owner1] = await token.functions.ownerOf(2);
        expect(owner1).to.equal(user3.address);

        const [owner2] = await token.functions.ownerOf(3);
        expect(owner2).to.equal(user3.address);

        const [totalSupply] = await token.functions.totalSupply();
        expect(totalSupply.toNumber()).to.equal(4); // tokenId=1

        // Traitsに指定した都道府県名が設定される
        const [traits1] = await provider.functions.generateTraits(1);
        const [traits2] = await provider.functions.generateTraits(2);
        const [traits3] = await provider.functions.generateTraits(3);
        // head,accessoryがランダムなので県のみチェック(head,accessoryは目視)
        console.log('multiple mint',traits1);
        console.log('multiple mint',traits2);
        console.log('multiple mint',traits3);
        expect(traits1.includes('{"trait_type": "prefecture" , "value":"Toyama"}')).to.equal(true);
        expect(traits2.includes('{"trait_type": "prefecture" , "value":"Toyama"}')).to.equal(true);
        expect(traits3.includes('{"trait_type": "prefecture" , "value":"Toyama"}')).to.equal(true);

        // 都道府県ごとのミント数
        const [mintNumberPerPrefecture] = await provider.functions.mintNumberPerPrefecture(16);
        expect(mintNumberPerPrefecture.toNumber()).to.equal(3); // tokenId=1

    });

    it('tokenGate', async function () {

        await minter.connect(owner).functions.setPhase(1);
        const [phaze] = await minter.functions.phase();
        expect(phaze).to.equal(1); // PreSale

        const txParams = { value: ethers.utils.parseUnits("0.009", "ether") };
        await expect(minter.connect(user4).functions.mintSelectedPrefecture(1, 1, txParams))
            .revertedWith('TokenGate token is needed');

        // sampleTokenをミント 
        await sampleToken.connect(user4).functions.mint();

        await minter.connect(user4).functions.mintSelectedPrefecture(1, 3, txParams);

        const [balance] = await token.functions.balanceOf(user4.address);

        expect(balance.toNumber()).to.equal(3); // user4は3つ追加

        await minter.connect(owner).functions.setPhase(2);
        const [phaze2] = await minter.functions.phase();
        expect(phaze2).to.equal(2); // PublicSale

    });

    it('Send eth', async function () {

        await minter.connect(owner).functions.setPhase(2);
        const [phaze] = await minter.functions.phase();
        expect(phaze).to.equal(2); // PreSale

        // 都道府県指定 OKパターンは'multiple mint'テストで実施
        const txParams = { value: ethers.utils.parseUnits("0.0059", "ether") };
        await expect(minter.connect(user4).functions.mintSelectedPrefecture(1, 2, txParams))
            .revertedWith('Must send the mint price');

        // 都道府県指定なし OKパターンは'mint from minter'テストで実施
        const txParams2 = { value: ethers.utils.parseUnits("0.0019", "ether") };
        await expect(minter.connect(user4).functions.mintSelectedPrefecture(0, 2, txParams2))
            .revertedWith('Must send the mint price');

    });

describe('P2P', function () {
    let tx, result, tokenId1: number;
    const zeroAddress = '0x0000000000000000000000000000000000000000';
    const price = ethers.BigNumber.from('1000000000000000');

    it('not on sale', async function () {

        const txParams = { value: ethers.utils.parseUnits("0.003", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(10, 1, txParams);
        result = await token.totalSupply();
        tokenId1 = result.toNumber() - 1;

        // セールなし
        await expect(token.connect(user2).purchase(tokenId1, user2.address, zeroAddress)).revertedWith('Token is not on sale');
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

        const balance1 = await ethers.provider.getBalance(user1.address);
        const balanceT = await ethers.provider.getBalance(owner.address);

        await token.connect(user2).purchase(tokenId1, user2.address, zeroAddress, { value: price });
        result = await token.ownerOf(tokenId1);
        expect(result).equal(user2.address);

        const balance12 = await ethers.provider.getBalance(user1.address);
        expect(balance12.sub(balance1)).equal(price.div(20).mul(19)); // 95%
        const balanceT2 = await ethers.provider.getBalance(owner.address);
        expect(balanceT2.sub(balanceT)).equal(price.div(20).mul(1)); // 5%

    });

    it('Attempt to setprice/buy by user1', async function () {
        await expect(token.connect(user1).purchase(0, user2.address, zeroAddress, { value: price })).revertedWith('Token is not on sale');
        await expect(token.connect(user1).setPriceOf(tokenId1, price)).revertedWith('Only the onwer can set the price');
    });
});

describe('P2PTradable', function () {
    let result, tx, err, balance, tokenId1: number, tokenId2: number;

    it('mint for test', async function () {
        // for user1
        const txParams = { value: ethers.utils.parseUnits("0.003", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(5, 1, txParams);
        result = await token.totalSupply();
        tokenId1 = result.toNumber() - 1;

        // for user2
        await minter.connect(user2).functions.mintSelectedPrefecture(10, 1, txParams);
        result = await token.totalSupply();
        tokenId2 = result.toNumber() - 1;

    });

    it('Attempt to super functions', async function () {
        await expect(token.connect(user2).executeTrade(tokenId2, tokenId1)).revertedWith('Cannot use this function');

        await expect(token.connect(user2).putTrade(tokenId1, true)).revertedWith('Cannot use this function');

    });

    it('Attempt to trade non-tradable token', async function () {
        await expect(token.connect(user2).executeTradeLocalNoun(tokenId2, tokenId1)).revertedWith('TargetTokenId is not on trade');
    });

    it('Attempt to execute trade non-owner token', async function () {
        await expect(token.connect(user2).executeTradeLocalNoun(tokenId1, tokenId2)).revertedWith('Only the onwer can trade');
    });

    it('Attempt to put trade non-owner token', async function () {
        await expect(token.connect(user2).putTradeLocalNoun(tokenId1, [])).revertedWith('Only the onwer can trade');
    });

    it('incorrect prefecutre id', async function () {
        await expect(token.connect(user2).putTradeLocalNoun(tokenId1, [0])).revertedWith('incorrect prefecutre id');
        await expect(token.connect(user2).putTradeLocalNoun(tokenId1, [48])).revertedWith('incorrect prefecutre id');
    });

    it('put trade', async function () {
        // 希望都道府県外のトークンと交換しようとする
        await token.connect(user1).putTradeLocalNoun(tokenId1, [1, 11, 12]);
        await expect(token.connect(user2).executeTradeLocalNoun(tokenId2, tokenId1)).revertedWith('unmatch to the wants list');

        result = await token.connect(user1).getTradePrefectureFor(tokenId1);
        expect(result.length).equal(3);
        expect(result[0].toNumber()).equal(1);
        expect(result[1].toNumber()).equal(11);
        expect(result[2].toNumber()).equal(12);

        await token.connect(user1).putTradeLocalNoun(tokenId1, [10, 11, 12]);
        result = await token.connect(user1).trades(tokenId1);
        expect(result).equal(true);

        tx = await token.connect(user2).executeTradeLocalNoun(tokenId2, tokenId1);
        await tx.wait();
        result = await token.connect(user1).trades(tokenId1);
        expect(result).equal(false);  //トレードリストから解除

        result = await token.connect(user1).ownerOf(tokenId1);
        expect(result).equal(user2.address);

        result = await token.connect(user1).ownerOf(tokenId2);
        expect(result).equal(user1.address);
    });

    it('put trade(都道府県指定なし)', async function () {
        // for user1
        const txParams = { value: ethers.utils.parseUnits("0.003", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(10, 1, txParams);
        result = await token.totalSupply();
        tokenId1 = result.toNumber() - 1;

        // for user2
        await minter.connect(user2).functions.mintSelectedPrefecture(10, 1, txParams);
        result = await token.totalSupply();
        tokenId2 = result.toNumber() - 1;

        // 希望都道府県なしでトレードリストに出す
        await token.connect(user1).putTradeLocalNoun(tokenId1, []);

        result = await token.connect(user1).trades(tokenId1);
        expect(result).equal(true);

        result = await token.connect(user1).getTradePrefectureFor(tokenId1);
        expect(result.length).equal(0);

        tx = await token.connect(user2).executeTradeLocalNoun(tokenId2, tokenId1);
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
        const txParams = { value: ethers.utils.parseUnits("0.003", "ether") };
        await minter.connect(user1).functions.mintSelectedPrefecture(10, 1, txParams);
        result = await token.totalSupply();
        tokenId1 = result.toNumber() - 1;

        // for user2
        await minter.connect(user2).functions.mintSelectedPrefecture(10, 1, txParams);
        result = await token.totalSupply();
        tokenId2 = result.toNumber() - 1;

        // 希望都道府県なしでトレードリストに出す
        await token.connect(user1).putTradeLocalNoun(tokenId1, []);

        result = await token.connect(user1).trades(tokenId1);
        expect(result).equal(true);

        // オーなー以外がキャンセルしようとする
        await expect(token.connect(user2).cancelTradeLocalNoun(tokenId1)).revertedWith('Only the onwer can trade');

        // オーなーがキャンセルする
        await token.connect(user1).cancelTradeLocalNoun(tokenId1);
        result = await token.connect(user1).trades(tokenId1);
        expect(result).equal(false);  //トレードリストから解除

        await expect(token.connect(user2).executeTradeLocalNoun(tokenId2, tokenId1)).revertedWith('TargetTokenId is not on trade');

    });

});
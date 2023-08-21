import { expect } from 'chai';
import { ethers, network, SignerWithAddress, Contract } from "hardhat";
import { addresses } from '../../src/utils/addresses';
import { ethers } from 'ethers';

let owner: SignerWithAddress, user1: SignerWithAddress, user2: SignerWithAddress;
let token: Contract, minter: Contract, provider: Contract;

const nounsDescriptorAddress = addresses.nounsDescriptor[network.name];
const localNounsDescriptorAddress = addresses.localNounsDescriptor[network.name];
const nounsSeederAddress = addresses.nounsSeeder[network.name];
const localSeederAddress = addresses.localSeeder[network.name];


before(async () => {
    /* `npx hardhat node`実行後、このスクリプトを実行する前に、Nouns,LocalNounsの関連するコントラクトを
     * デプロイする必要があります。(一度実行すると、node停止までは再実施する必要なし)
        # cd contract
        # npx hardhat run scripts/deploy_nounsDescriptorV1.ts
        # npx hardhat run scripts/populate_nounsV1.ts
        # npx hardhat run scripts/deploy_localNouns.ts
        # npx hardhat run scripts/populate_localNouns.ts
     */

    [owner, user1, user2] = await ethers.getSigners();

    const factoryProvider = await ethers.getContractFactory('LocalNounsProvider');
    provider = await factoryProvider.deploy(
        nounsDescriptorAddress, localNounsDescriptorAddress, nounsSeederAddress, localSeederAddress);
    await provider.deployed();
    console.log(`##LocalNounsProvider="${provider.address}"`);

    const factoryToken = await ethers.getContractFactory('LocalNounsToken');
    token = await factoryToken.deploy(provider.address, owner.address);
    await token.deployed();
    console.log(`##LocalNounsToken="${token.address}"`);

    const factoryMinter = await ethers.getContractFactory('LocalNounsMinter');
    minter = await factoryMinter.deploy(token.address);
    await minter.deployed();
    console.log(`##LocalNounsMinter="${minter.address}"`);

    await token.setMinter(minter.address);

});

describe('mint functions', function () {
    let result, tx;
    it('mint from non-minter', async function () {
        await expect(token.connect(user1).functions.mint())
            .revertedWith('Cannot use this function');

        await expect(token.connect(user1).functions.mintSelectedPrefecture(user1.address, 1))
            .revertedWith('Sender is not the minter');

    });

    it('mint from minter', async function () {
        await minter.connect(user1).functions.mintSelectedPrefecture(1);

        const [balance] = await token.functions.balanceOf(user1.address);
        expect(balance.toNumber()).to.equal(1); // user1は1つ保持

        const [owner0] = await token.functions.ownerOf(0);
        expect(owner0).to.equal(user1.address);

        const [totalSupply] = await token.functions.totalSupply();
        expect(totalSupply.toNumber()).to.equal(1); // tokenId=1
    });

    it('batch mint', async function () {

        //Aomori,Iwate,Miyagiを1個,2個,3個ずつ、user2にmint
        await minter.connect(user2).functions.mintSelectedPrefectureBatch([2, 3, 4], [1, 2, 3]);

        // user2に合計6個ミントされる
        const [balance] = await token.functions.balanceOf(user2.address);
        expect(balance.toNumber()).to.equal(1 + 2 + 3);

        const [owner1] = await token.functions.ownerOf(1);
        const [owner2] = await token.functions.ownerOf(2);
        const [owner3] = await token.functions.ownerOf(3);
        const [owner4] = await token.functions.ownerOf(4);
        const [owner5] = await token.functions.ownerOf(5);
        const [owner6] = await token.functions.ownerOf(6);

        expect(owner1).to.equal(user2.address);
        expect(owner2).to.equal(user2.address);
        expect(owner3).to.equal(user2.address);
        expect(owner4).to.equal(user2.address);
        expect(owner5).to.equal(user2.address);
        expect(owner6).to.equal(user2.address);

        // Traitsに指定した都道府県名が設定される
        const [traits1] = await provider.functions.generateTraits(1);
        const [traits2] = await provider.functions.generateTraits(2);
        const [traits3] = await provider.functions.generateTraits(3);
        const [traits4] = await provider.functions.generateTraits(4);
        const [traits5] = await provider.functions.generateTraits(5);
        const [traits6] = await provider.functions.generateTraits(6);
        expect(traits1).to.equal('{"trait_type": "prefecture" , "value":"Aomori"}');
        expect(traits2).to.equal('{"trait_type": "prefecture" , "value":"Iwate"}');
        expect(traits3).to.equal('{"trait_type": "prefecture" , "value":"Iwate"}');
        expect(traits4).to.equal('{"trait_type": "prefecture" , "value":"Miyagi"}');
        expect(traits5).to.equal('{"trait_type": "prefecture" , "value":"Miyagi"}');
        expect(traits6).to.equal('{"trait_type": "prefecture" , "value":"Miyagi"}');

        const [totalSupply] = await token.functions.totalSupply();
        expect(totalSupply.toNumber()).to.equal(7);
    });
});

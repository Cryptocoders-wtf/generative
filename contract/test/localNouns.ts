import { expect } from 'chai';
import { ethers, network, SignerWithAddress, Contract } from "hardhat";
import { addresses } from '../../src/utils/addresses';
import { ethers } from 'ethers';

let owner: SignerWithAddress, user1: SignerWithAddress;
let token: Contract, minter: Contract;
const localProviderAddress = addresses.localProvider[network.name];

before(async () => {
    /* `npx hardhat node`実行後、このスクリプトを実行する前に、Nouns,LocalNounsの関連するコントラクトを
     * デプロイする必要があります。(一度実行すると、node停止までは再実施する必要なし)
        # cd contract
        # npx hardhat run scripts/deploy_nounsDescriptorV1.ts
        # npx hardhat run scripts/populate_nounsV1.ts
        # npx hardhat run scripts/deploy_localNouns.ts
        # npx hardhat run scripts/populate_localNouns.ts
     */

    [owner, user1] = await ethers.getSigners();

    const factoryToken = await ethers.getContractFactory('LocalNounsToken');
    token = await factoryToken.deploy(localProviderAddress, owner.address);
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

        const [totalSupply] = await token.functions.totalSupply();
        expect(totalSupply.toNumber()).to.equal(1); // tokenId=1
    });
});

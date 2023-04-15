import { expect } from 'chai';
import { ethers, SignerWithAddress, Contract } from 'hardhat';

let owner: SignerWithAddress,
  artist: SignerWithAddress,
  user1: SignerWithAddress,
  user2: SignerWithAddress,
  user3: SignerWithAddress;
let token: Contract, token1: Contract, token2: Contract, token3: Contract;
let balanceO, balanceA, balance1, balance2, balance3;

before(async () => {
  [owner, user1, user2, user3] = await ethers.getSigners();
  artist = owner;

  // const factory = await ethers.getContractFactory('SampleP2PToken');
  // token = await factory.deploy(artist.address);
  const factorySVGStore = await ethers.getContractFactory('SVGStoreV1');
  const store = await factorySVGStore.deploy();
  console.log('1');
  const factorySVGProvider = await ethers.getContractFactory('SVGImage1Provider');
  const provider = await factorySVGProvider.deploy(store.address);
  console.log('2');
  const factorySVGToken = await ethers.getContractFactory('SVGTokenV1');
  token = await factorySVGToken.deploy(provider.address, store.address);

  await token.deployed();

  token1 = token.connect(user1);
  token2 = token.connect(user2);
  token3 = token.connect(user3);
});

const svgdata = {
  paths: [
    '0x4d50bc270673f754f4f56427fe54c6fe54c663500000554e0d557c0c05734e45fb4f45ea05358a0835610435bdfe34af6350000045a1fa447efb04739d54029954016350000045bd6445ac8005530955fb0a650d63500000551b14554b1f057346550f4b550f1845f91c45ed5a00',
  ],
  fills: ['pink'],
  strokes: [0],
  matrixes: [''],
};

describe('SVGImage P2P', function () {
  let result, tx, err, balance;
  const zeroAddress = '0x0000000000000000000000000000000000000000';
  const price = ethers.BigNumber.from('1000000000000000');
  const tokenId0 = 0;
  console.log(ethers.utils.formatEther(price));

  it('Initial TotalSupply', async function () {
    result = await token.totalSupply();
    expect(result.toNumber()).equal(0);
    result = await token.balanceOf(user1.address);
    expect(result.toNumber()).equal(0);
  });
  it('Mint by user1', async function () {
    tx = await token1.mintWithAsset(svgdata);

    await tx.wait();
    result = await token.totalSupply();
    expect(result.toNumber()).equal(1);
  });
  it('Check Owner', async function () {
    result = await token.balanceOf(user1.address);
    expect(result.toNumber()).equal(1);
    result = await token.ownerOf(tokenId0);
    expect(result).equal(user1.address);
  });
  it('Check Price', async function () {
    result = await token.getPriceOf(tokenId0);
    expect(result.toNumber()).equal(0);
  });
  it('Attempt to buy by user2', async function () {
    await expect(token2.purchase(0, user2.address, zeroAddress)).revertedWith('Token is not on sale');
  });
  it('SetPrice', async function () {
    await expect(token2.setPriceOf(tokenId0, price)).revertedWith('Only the onwer can set the price');
    tx = await token1.setPriceOf(tokenId0, price);
    await tx.wait();
    result = await token.getPriceOf(tokenId0);
    expect(result.toNumber()).equal(price);
  });
  it('Purchase by user2', async function () {
    await expect(token2.purchase(tokenId0, user2.address, zeroAddress)).revertedWith('Not enough fund');

    balance1 = await token.etherBalanceOf(user1.address);
    balanceA = await token.etherBalanceOf(artist.address);

    tx = await token2.purchase(tokenId0, user2.address, zeroAddress, { value: price });
    await tx.wait();
    result = await token.ownerOf(tokenId0);
    expect(result).equal(user2.address);
  });
  it('Balance Check', async function () {
    balance = await token.etherBalanceOf(user1.address);
    expect(balance.sub(balance1)).equal(price); // 100%
    // expect(balance.sub(balance1)).equal(price.div(20).mul(19)); // 95%
    // balance = await token.balanceOf(artist.address);
    // expect(balance.sub(balanceA)).equal(price.div(20).mul(1)); // 5%
  });
  it('Attempt to buy by user3', async function () {
    await expect(token3.purchase(0, user2.address, zeroAddress, { value: price })).revertedWith('Token is not on sale');
  });
});

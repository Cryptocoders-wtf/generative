import { expect } from 'chai';
import { ethers, SignerWithAddress, Contract } from 'hardhat';

let store: Contract, provider: Contract, token: Contract, tokenFactory: Contract, tokenFactory2: Contract, token3: Contract;
let balanceO, balanceA, balance1, balance2, balance3;

const data = {
  paths: [
    '0x4d50bc270673f754f4f56427fe54c6fe54c663500000554e0d557c0c05734e45fb4f45ea05358a0835610435bdfe34af6350000045a1fa447efb04739d54029954016350000045bd6445ac8005530955fb0a650d63500000551b14554b1f057346550f4b550f1845f91c45ed5a00',
  ],
  fills: ['pink'],
  strokes: [0],
  matrixes: [''],
};

before(async () => {

  const factoryStore = await ethers.getContractFactory('SVGStoreV1');
  store = await factoryStore.deploy();

  const factoryProvider = await ethers.getContractFactory('SVGImage1Provider');
  provider = await factoryProvider.deploy(store.address);

  const factoryToken = await ethers.getContractFactory('SVGTokenV1');
  token = await factoryToken.deploy(provider.address, store.address);

  await token.deployed();

  const tx = await token.mintWithAsset(data);
  await tx.wait();

  const factoryCopy = await ethers.getContractFactory('TokenFactory');
  tokenFactory = await factoryCopy.deploy(token.address);
  await tokenFactory.deployed();

  const factoryCopy2 = await ethers.getContractFactory('TokenFactory2');
  tokenFactory2 = await factoryCopy2.deploy(token.address);
  await tokenFactory2.deployed();

});

describe('Copy', function () {
  it('TokenFactory', async function () {
    const tx = await tokenFactory.forkContract(0);
    const ret = await tx.wait();
    await tx2.wait();

    console.log(hoge);
    console.log(hoge.assetProvider);
    console.log(hoge.assetId);
  });

  it('TokenFactory2', async function () {
    const tx = await tokenFactory.forkContract(0);
    const ret = await tx.wait();
    console.log(ret.events);
    // console.log(hoge.assetProvider);
    // console.log(hoge.assetId);
  });

});

import { expect } from 'chai';
import { ethers } from 'hardhat';

let asset: Contract, token: Contract, provider: Contract;

const committee = '0x818Fb9d440968dB9fCB06EEF53C7734Ad70f6F0e'; // ai

before(async () => {
  const factory1 = await ethers.getContractFactory('LuPartsLu1');
  const parts1 = await factory1.deploy();
  await parts1.deployed();

  const factory2 = await ethers.getContractFactory('LuArt1');
  const artAsset = await factory2.deploy([parts1.address]);
  await artAsset.deployed();
  
  const factory3 = await ethers.getContractFactory('LuArtProvider');
  provider = await factory3.deploy(artAsset.address);
  await provider.deployed();
  
  const factory4 = await ethers.getContractFactory('LuToken');
  token = await factory4.deploy(provider.address, committee);
  await token.deployed();
});
describe('LuArt', function () {
  it('Empty Text 2 Array', async function () {
    let tx = await token.mint({value: ethers.utils.parseEther("0.1")});
    await tx.wait();

    tx = await token.mint({value: ethers.utils.parseEther("0.1")});
    await tx.wait();

    for(let i = 0; i < 100; i ++){
      const ret = await provider.generateTraits(i)
      console.log(ret);
    }
    
  });
});


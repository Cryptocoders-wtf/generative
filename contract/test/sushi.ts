import { expect } from 'chai';
import { ethers, SignerWithAddress, Contract } from 'hardhat';

import { chunkArray } from "./utils/utils";
import { data } from "./image-sushi-data";

import * as fs from 'fs';

// sushi need mainnet forking.
// you need run all test on mainnet forking

let token: Contract, sushiNounsDescriptor: Contract, token1: Contract, provider: Contract, token2: Contract;

before(async () => {
  const descriptor = "0x0cfdb3ba1694c2bb2cfacb0339ad7b1ae5932b63";
  const seeder = "0xcc8a0fb5ab3c7132c1b2a0109142fb112c4ce515";

  const committee = "0x4E4cD175f812f1Ba784a69C1f8AC8dAa52AD7e2B";
  const developper = "0x4e357ffB3ea723aCC30530eddde89c6Dbb2Db74e"; // ai
  
  const factorySeeder = await ethers.getContractFactory('NounsSushiSeeder');
  const sushiseeder = await factorySeeder.deploy();
  await sushiseeder.deployed();

  const factoryNFTDescriptor2 = await ethers.getContractFactory('NFTDescriptor2');
  const nftDescriptor = await factoryNFTDescriptor2.deploy();
  await nftDescriptor.deployed();
  
  const factorySushiNounsDescriptor = await ethers.getContractFactory('SushiNounsDescriptor', {
    libraries: {
      NFTDescriptor2: nftDescriptor.address,
    }
  });
  sushiNounsDescriptor = await factorySushiNounsDescriptor.deploy(
    descriptor
  );
  await sushiNounsDescriptor.deployed();
  
  
  const factorySVGStore = await ethers.getContractFactory('SushiNounsProvider');
  provider = await factorySVGStore.deploy(descriptor, sushiNounsDescriptor.address, seeder, sushiseeder.address);

  const factoryToken = await ethers.getContractFactory('SushiNounsToken');
  token = await factoryToken.deploy(provider.address, committee, developper, developper);

  
});

describe('Sushi', function () {
  it('hello sushi', async function () {
    this.timeout(1000 * 60 * 60)
    await sushiNounsDescriptor.addManyColorsToPalette(0, data.palette);

    const accessoryChunk = chunkArray(data.images.accessories, 10);
    for (const chunk of accessoryChunk) {
      await sushiNounsDescriptor.addManyAccessories(chunk.map(({ data }) => data));
      console.log("accessory");
    }

    // hack, sushi use body as backgrounds because of background is string but we
    /*
    const backgroundChunk = chunkArray(data.images.backgrounds, 10);
    for (const chunk of backgroundChunk) {
      await sushiNounsDescriptor.addManyBodies(chunk.map(({ data }) => data));
      console.log("b");
    }
    for (const chunk of backgroundChunk) {
      await sushiNounsDescriptor.addManyBackgrounds(chunk.map(({ data }) => data));
      console.log("b2");
    }
    */

    const headChunk = chunkArray(data.images.heads, 10);
    for (const chunk of headChunk) {
      await sushiNounsDescriptor.addManyHeads(chunk.map(({ data }) => data));
      console.log("h");
    }
    console.log("ok");
    
    const ret1 = await provider.generateSVGPart(100);
    for (let i = 1; i<50; i ++) {
      await token.mint({value: 1});
      // await provider.mint(i);
      const ret = await provider.generateSVGPart(i);
      //console.log(ret);
      console.log(await token.totalSupply());
      const base64 = ret.svgPart;
      const svg = Buffer.from(base64, 'base64').toString();
      
      fs.writeFileSync(`./svg/${i}.svg`, svg, { encoding: 'utf8' });
    }
    console.log("hjello");
  })
});

import { expect } from 'chai';
import { ethers, SignerWithAddress, Contract } from 'hardhat';

import { chunkArray } from "./utils/utils";
import { data } from "./image-sushi-data";

import * as fs from 'fs';


let token: Contract, sushiNounsDescriptor: Contract, token1: Contract, token2: Contract, token3: Contract;

before(async () => {
  const descriptor = "0x0cfdb3ba1694c2bb2cfacb0339ad7b1ae5932b63";
  const seeder = "0xcc8a0fb5ab3c7132c1b2a0109142fb112c4ce515";

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
  /*
  INounsDescriptor _descriptor,
        INounsDescriptor _sushidescriptor,
        INounsSeeder _seeder,
        address _developer,
        address _committee,
        PriceSeed memory _priceSeed,
        IProxyRegistry _proxyRegistry
  */
  token1 = await factorySVGStore.deploy(descriptor, sushiNounsDescriptor.address, seeder, sushiseeder.address);

  // insert backgrounds to sushiNounsDescriptor
  // insert head to sushiNounsDescriptor
  
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
    const backgroundChunk = chunkArray(data.images.backgrounds, 10);
    for (const chunk of backgroundChunk) {
      await sushiNounsDescriptor.addManyBodies(chunk.map(({ data }) => data));
      console.log("b");
    }
    for (const chunk of backgroundChunk) {
      await sushiNounsDescriptor.addManyBackgrounds(chunk.map(({ data }) => data));
      console.log("b");
    }

    const headChunk = chunkArray(data.images.heads, 10);
    for (const chunk of headChunk) {
      await sushiNounsDescriptor.addManyHeads(chunk.map(({ data }) => data));
      console.log("h");
    }
    console.log("ok");
    // console.log(await sushiNounsDescriptor.backgroundCount())
    
    for (let i = 1; i<50; i ++) {
      const ret = await token1.generateSVGPart(i);
      console.log(ret);
      const base64 = ret.svgPart.split(";")[1].split(",")[1]
      const json = JSON.parse(Buffer.from(base64, 'base64').toString());
      const image = json.image;
      const svgBase64 = image.split(";")[1].split(",")[1];
      const svg = Buffer.from(svgBase64, 'base64').toString();
      
      fs.writeFileSync(`./svg/${i}.svg`, svg, { encoding: 'utf8' });
    }
    console.log(svg);
    console.log("hjello");
  })
});

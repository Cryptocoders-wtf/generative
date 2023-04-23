import { ethers, network } from 'hardhat';
import { writeFile } from 'fs';

const deploy = async (name: string, args: any) => {
  const factory = await ethers.getContractFactory(name);
  const contract = args ? await factory.deploy(args) : await factory.deploy();
  await contract.deployed();
  return contract;
  // console.log(`      test="${contract.address}"`);
};

const deployNFT = async (name: string, args: any, args2: any) => {
  const factory = await ethers.getContractFactory(name);
  const contract = await factory.deploy(args, args2);
  await contract.deployed();
  return contract;
  // console.log(`      test="${contract.address}"`);
};
async function main() {
  const cons = [
    "LuPartsBg",
    "LuPartsChair",
    "LuPartsCloudRainbow",
    "LuPartsClouds",
    "LuPartsDoorsetA",
    "LuPartsDoorsetB",
    "LuPartsDoorsetC",
    "LuPartsHeartA",
    "LuPartsHeartB",
    "LuPartsHeartC",
    "LuPartsHeartcloud",
    "LuPartsHouseBase",
    "LuPartsLu01",
    "LuPartsLu02body2",
    "LuPartsLu02head1",
    "LuPartsLu02head2",
    "LuPartsPlane",
    "LuPartsRainbowA",
    "LuPartsRoofA",
    "LuPartsRoofB",
    "LuPartsRoofC",
  ];

  const partsList = [];
  for await (let con of cons) {
    const partsContract = await deploy(con);
    await partsContract.deployed();
    // console.log(con);
    console.log(`      parts="${partsContract.address}"`);
    // await contract.register(con, partsContract.address);
    partsList.push(partsContract.address);
  }
  console.log({partsList});
  
  const contract = await deploy('LuArt1', partsList);
  await contract.deployed();
  console.log(`      asset="${contract.address}"`);
  // const result = await contract.getParts(2);
  // const result2 = await contract.Roof05()
/*
  for (let i = 0; i < 500; i++) {
    const resultData = await contract.getSVG(i);
    const ret = await contract.generateTraits(i)
    console.log(i, ret);
    await writeFile(`./cache/lu_test${i}.svg`, resultData, () => {});
    }
    */
/*
  for (let i = 0; i < 5; i++) {
    const j = i * 12 + 5;
    const resultData = await contract.getSVG(j);
    console.log(j);
    await writeFile(`./cache/lu_test${j}.svg`, resultData, () => {});
  }

  for (let i = 0; i < 3; i++) {
    const j = i * 60 + 4;
    const resultData = await contract.getSVG(j);
    console.log(j);
    await writeFile(`./cache/lu_test${j}.svg`, resultData, () => {});
  }
*/
  
  //const result3 = await contract.getSVG(0);
  //const result4 = await contract.getSVG(1);
  //const result5 = await contract.getSVG(2);

  // await writeFile(`./cache/lu_test.svg`, result3, () => {});
  //  await writeFile(`./cache/lu_test1.svg`, result4, () => {});
  // await writeFile(`./cache/lu_test2.svg`, result5, () => {});
  // console.log(result);
  // console.log(result2);
/*
  console.log(result3);
  console.log('---------');
  console.log(result4);
  console.log('---------');
  console.log(result5);
  console.log('---------');
*/
  /////

  const providerContract = await deploy('LuArtProvider', contract.address);
  await providerContract.deployed();

  console.log(`      prodider="${providerContract.address}"`);
//  const result6 = await providerContract.generateSVGDocument(0);
  // await writeFile(`./cache/lu_test6.svg`, result6, () => {});

  const committee = '0x818Fb9d440968dB9fCB06EEF53C7734Ad70f6F0e'; // ai
  const factoryToken = await ethers.getContractFactory('LuToken');
  const token = await factoryToken.deploy(providerContract.address, committee);
  await token.deployed();
  console.log(`      tokenContract="${token.address}"`);

  //  await token.mint();
  console.log('mint');
  await token.mint();
  //  await token.mint( { value: ethers.utils.parseEther("0.01") });
  //  await token.mint( { value: ethers.utils.parseEther("0.01") });
  //  await token.mint( { value: ethers.utils.parseEther("1") });
  // await token.mint();
  // await token.mint();

  // const svg = await token.tokenURI(5);
  // console.log(svg);

  //////
  /*  
  const factory = await ethers.getContractFactory("LuToken");
  const contract2 = await factory.deploy("Lu", "Lu", contract.address);
  await contract2.deployed();
  console.log(`      nft="${contract2.address}"`);
  const hoge = await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  const svg = await contract2.tokenURI(1);
  console.log(svg);
*/

  /*
  const contract = await deployNFT("LuToken", "Lu", "Lu");
  console.log(`      test="${contract.address}"`);
  */
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

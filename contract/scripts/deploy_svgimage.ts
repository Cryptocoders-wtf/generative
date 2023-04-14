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
  const data = {
    paths: [
      '0x4d50bc270673f754f4f56427fe54c6fe54c663500000554e0d557c0c05734e45fb4f45ea05358a0835610435bdfe34af6350000045a1fa447efb04739d54029954016350000045bd6445ac8005530955fb0a650d63500000551b14554b1f057346550f4b550f1845f91c45ed5a00',
    ],
    fills: ['pink'],
    strokes: [0],
    matrixes: [''],
  };
  console.log(data);

  const factorySVGStore = await ethers.getContractFactory('SVGStoreV1');
  const store = await factorySVGStore.deploy();
  console.log('1');
  const factorySVGProvider = await ethers.getContractFactory('SVGImage1Provider');
  const provider = await factorySVGProvider.deploy(store.address);
  console.log('2');

  const factorySVGToken = await ethers.getContractFactory('SVGTokenV1');
  const token = await factorySVGToken.deploy(provider.address, store.address);

  // mint 0
  await token.mintWithAsset(data);

  // const res = await store.getSVG(1);
  // console.log(res);

  // const nft0 = await token.tokenURI(0);
  // console.log("---nft0---");
  // console.log(nft0);
  /*
  const nft1 = await token.tokenURI(1);
  console.log("---nft1---");
  console.log(nft1);
*/
  /*
  // for hack
  await store.register(data);

  // mint 1
  await token.mintWithAsset(data)
  const nft1 = await token.tokenURI(1);
  console.log("---nft1---");
  console.log(nft1);
  */

  console.log(`store      contract="${store.address}"`);
  console.log(`provider      contract="${provider.address}"`);
  console.log(`token      contract="${token.address}"`);

  //console.log(res3);

  //console.log(res.fills);
  //console.log(res.paths);
  //console.log(res.strokes);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

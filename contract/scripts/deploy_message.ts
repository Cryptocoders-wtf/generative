import { ethers, network } from 'hardhat';
import { writeFile } from 'fs';
import { addresses } from '../../src/utils/addresses';

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
  const factorySVGStore = await ethers.getContractFactory('MessageStoreV1');

  // const store = await factorySVGStore.deploy(addresses.londrina_solid.mainnet); // mainnet font.
  console.log("1");
  const store = await factorySVGStore.deploy(addresses.londrina_solid.goerli); // goerli font.

  console.log("2");
  await store.register({ message: 'hello', color: '#000' });
  console.log("2");
  const res = await store.getSVG(0);
  // console.log(res);

  console.log("3");
  const factoryMessageProvider = await ethers.getContractFactory('MessageProvider2');

  // const provider = await factoryMessageProvider.deploy(store.address, addresses.alphabet.mainnet);
  // const provider = await factoryMessageProvider.deploy(store.address, addresses.pnouns.mainnet);

  // const provider = await factoryMessageProvider.deploy(store.address, addresses.splatter.mainnet);
  const provider = await factoryMessageProvider.deploy(store.address, addresses.splatter.goerli);

  // const provider = await factoryMessageProvider.deploy(store.address, addresses.snowArt.goerli); // go
  console.log("4");


  console.log("5");
  const factoryMessageToken = await ethers.getContractFactory('MessageToken');
  const token = await factoryMessageToken.deploy(provider.address, store.address);

  console.log("6");
  // mint 0
  await token.mintWithAsset({ message: 'first nft!', color: 'orange' });
  await token.mintWithAsset({ message: 'first nft!', color: 'orange' });
  console.log("7");

  await token.mintWithAsset({ message: 'first nft!', color: 'orange' });
  console.log("8");

  // const res = await store.getSVG(1);
  // console.log(res);

/*
  const nft0 = await token.tokenURI(0);
  console.log('---nft0---');
  console.log(nft0);
*/
  
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
  /*
  const messageSVG = await store.getSVGMessage('This\n is\n a\n pen', 'pink', { w: 1024, h: 1024 });
  console.log(messageSVG);

  const testMessage = await store.test('This\nis\na\npen');
  console.log(testMessage);
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

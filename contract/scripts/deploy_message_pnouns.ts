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

  console.log("factorySVGStore.deploy");
  const store = await factorySVGStore.deploy(addresses.londrina_solid[network.name]); // font.

  console.log("wait");
  await store.deployed();
  console.log("ok");

  await store.register({ message: 'hello', color: '#000' });
  console.log("store.getSVG");
  const res = await store.getSVG(0);
  // console.log(res);

  console.log("factoryMessageProvider");
  const factoryMessageProvider = await ethers.getContractFactory('MessageProvider2');

  // const provider = await factoryMessageProvider.deploy(store.address, addresses.alphabet[network.name]);
  // const provider = await factoryMessageProvider.deploy(store.address, addresses.paperNouns[network.name]);
  const provider = await factoryMessageProvider.deploy(store.address, addresses.pnouns[network.name]);
  console.log("wait");
  await provider.deployed();
  console.log("ok");

  // const provider = await factoryMessageProvider.deploy(store.address, addresses.splatter[network.name]);
  // const provider = await factoryMessageProvider.deploy(store.address, addresses.snowArt[network.name]);

  console.log("factoryMessageToken");
  const factoryMessageToken = await ethers.getContractFactory('MessageToken');
  const token = await factoryMessageToken.deploy(provider.address, store.address);
  console.log("wait");
  await token.deployed();
  console.log("ok");

  console.log(`store      contract="${store.address}"`);
  console.log(`provider      contract="${provider.address}"`);
  console.log(`token      contract="${token.address}"`);

  console.log("mint");
  // mint 0
  await token.mintWithAsset({ message: 'first nft!', color: 'orange' });
  await token.mintWithAsset({ message: 'first nft!', color: 'orange' });
  await token.mintWithAsset({ message: 'first nft!', color: 'orange' });

}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

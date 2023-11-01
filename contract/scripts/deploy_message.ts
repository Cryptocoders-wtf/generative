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
  console.log(network.name);
  // const store = await factorySVGStore.deploy(addresses.londrina_solid[network.name]); // font.
  const store = await factorySVGStore.deploy(addresses.noto_sans[network.name]); // font.

  // for mainnet forking
  // const store = await factorySVGStore.deploy("0x980aAc123617e2B2ea407081Ceb72d5854BAa3D1"); // font.

  console.log("wait");
  await store.deployed();
  console.log("ok");

  await store.register({ message: 'hello1', color: '#000' });
  await store.register({ message: 'hello2', color: '#000' });
  await store.register({ message: 'hello3', color: '#000' });
  await store.register({ message: 'hello4', color: '#000' });
  console.log("store.getSVG");

  const res3 = await store.getMessage(3);
  console.log(res3);
  const res = await store.getSVG(0);
  // console.log(res);

  console.log("factoryMessageProvider");
  const factoryMessageProvider = await ethers.getContractFactory('MessageProvider2');

  // const provider = await factoryMessageProvider.deploy(store.address, addresses.alphabet[network.name]);
  // const provider = await factoryMessageProvider.deploy(store.address, addresses.pnouns[network.name]);
  const provider = await factoryMessageProvider.deploy(store.address, addresses.splatter[network.name]);
  console.log("wait");
  await provider.deployed();
  console.log("ok");

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
  await token.mintWithAsset({ message: '2nd nft!', color: 'orange' });
  await token.mintWithAsset({ message: '3rd nft!', color: 'orange' });

  const message = await token.getLatestMessage();
  console.log(message);
  const message1 = await token.getMessage(0);
  console.log(message1);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

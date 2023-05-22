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
  console.log("Network Name:", network.name);
  const box = {w: 1024, h: 1024};

  // --------------------------- MessageStoreV2 ---------------------------
  const factorySVGStore = await ethers.getContractFactory('MessageStoreV2');
  const store = await factorySVGStore.deploy();
  console.log("wait");
  await store.deployed();
  console.log(`store      contract="${store.address}"`);
  const storeAddress = `export const addresses = {\n` + `  messageStore: "${store.address}",\n` + `}\n`;
  writeFile(`../src/utils/addresses/messagestore2_${network.name}.ts`, storeAddress, () => {});

  // Goerli Test Net
  // await store.registerFont('Noto_Sans', '0xf4fd7f7e9fC89B2F539BE378214EbB768ECBf91B');
  // await store.registerFont('Londrina_Solid', '0xbFde916e6315365567F3504E20166F92474dc4ea');

  // Mumbai Test Net
  await store.registerFont('Noto_Sans', '0xCBbC30D7d8b9DCF720f4FfB98Ef42E5A2633B791');
  await store.registerFont('Londrina_Solid', '0xF3636358069588D2A16a81d27e7e8cB15Eb3827B');

  const is_ = await store.isFontRegistered('Londrina_Solid');
  console.log(is_);

  // await store.register({ message: 'hello1', color: '#000', fontName: 'Noto_Sans', assetName: 'Splatter' });
  // await store.register({ message: 'hello2', color: '#000', fontName: 'Noto_Sans', assetName: 'Splatter' });
  // await store.register({ message: 'hello3', color: '#000', fontName: 'Londrina_Solid', assetName: 'Splatter' });
  // await store.register({ message: 'hello4', color: '#000', fontName: 'Londrina_Solid', assetName: 'Splatter' });

  // const res3 = await store.getMessage(3);
  // console.log(res3);
  // const abc = await store.getSVGMessage("Hello,Hello", "#000", "Londrina_Solid", box);
  // console.log(abc);
  // ------------------------------------------------------------------------


  // // --------------------------- MessageProvider3 ---------------------------
  // const storeAddress = '0xb0c6B1FBd00900B60f5Ff5aeB46BF2d8c7708f23';
  const factoryMessageProvider = await ethers.getContractFactory('MessageProvider3');
  const provider = await factoryMessageProvider.deploy(store.address);
  console.log("wait");
  await provider.deployed();
  console.log(`provider      contract="${provider.address}"`);
  const providerAddress = `export const addresses = {\n` + `  messageProvider: "${provider.address}",\n` + `}\n`;
  writeFile(`../src/utils/addresses/messageprovider_${network.name}.ts`, providerAddress, () => {});

  // // Goerli Test Net
  // await provider.registerAsset('Splatter', '0x15C40F258B1fc68c109FE3E3CFF191a80f24E4C1');
  // await provider.registerAsset('Snow', '0xa92675Feb3a316d73ec9D8f2A0De7b90b25b1351');

  // Mumbai Test Net
  await provider.registerAsset('Splatter', '0x256Ba9c4DD146f3EBf0f7D0a3Ddea3F400CE806D');
  await provider.registerAsset('Snow', '0x00cF04ec45DE4Ed7e8451948dBa330f7bF614fda');

  // const is_Splatter = await provider.isAssetRegistered('Splatter');
  // const is_Snow = await provider.isAssetRegistered('Snow');
  // console.log(is_Splatter, is_Snow);
  // const id = await store.getNextPartIndex();
  // console.log(id.toNumber());
  // const aaa = await provider.generateSVGMessage("Hello,Hello", "orange", "Noto_Sans", 'Splatter', box);
  // console.log(aaa);
  // save to file
  // writeFile('test.svg', aaa, (err) => {
  //   if (err) throw err;
  //   console.log('The file has been saved!');
  // });
  // // ------------------------------------------------------------------------


  // // ----------------------------- MessegeToken -----------------------------
  // const providerAddress = '0x3249784e050D06b909117fA4405fe013E9490957';
  const factoryMessageToken = await ethers.getContractFactory('MessageTokenV2');
  const token = await factoryMessageToken.deploy(provider.address, store.address);
  console.log("wait");
  await token.deployed();
  console.log(`token      contract="${token.address}"`);
  const tokenAddress = `export const addresses = {\n` + `  messageToken: "${token.address}",\n` + `}\n`;
  writeFile(`../src/utils/addresses/messagetoken_${network.name}.ts`, tokenAddress, () => {});

  // // mint
  // await token.mintWithAsset({ message: 'first nft!', color: 'orange', fontName: 'Noto_Sans' , assetName: 'Snow'});
  // await token.mintWithAsset({ message: '2nd nft!', color: 'orange', fontName: 'Noto_Sans' , assetName: 'Snow'});
  // await token.mintWithAsset({ message: '3rd nft!', color: 'blue', fontName: 'Londrina_Solid' , assetName: 'Snow'});
  // await token.mintWithAsset({ message: '4th nft!', color: 'orange', fontName: 'Noto_Sans' , assetName: 'Snow'});

  // const message = await token.getLatestMessage();
  // console.log(message);
  // const message1 = await token.getMessage(0);
  // console.log(message1);

  // const nextId = await token.totalSupply();
  // console.log(nextId.toNumber());
  // const tokenId = nextId.toNumber() - 1;
  // console.log(tokenId);
  // const bbb = await token.getAsset(tokenId);
  // console.log(bbb.assetName);
  // const ret = await token.getAssetId(tokenId);
  // console.log(ret.toNumber());
  // const uri = await token.tokenURI(2);
  // console.log(uri);
  // // ------------------------------------------------------------------------
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

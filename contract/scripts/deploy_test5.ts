import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import addresses from '@nouns/sdk/dist/contract/addresses.json';

const nounsDescriptor:string = (network.name == "goerli") ?
  addresses[5].nounsDescriptor: addresses[1].nounsDescriptor;
const nounsToken:string = (network.name == "goerli") ?
  addresses[5].nounsToken: addresses[1].nounsToken;

async function main() {
  const factoryNouns = await ethers.getContractFactory("NounsAssetProvider");
  const nouns = await factoryNouns.deploy(nounsToken, nounsDescriptor);
  await nouns.deployed();
  console.log(`      nouns="${nouns.address}"`);

  const factoryDotNouns = await ethers.getContractFactory("DotNounsProvider");
  const dotNouns = await factoryDotNouns.deploy(nouns.address);
  await dotNouns.deployed();
  console.log(`      nouns="${dotNouns.address}"`);

  const factory = await ethers.getContractFactory("SVGTest5Nouns");
  const contract = await factory.deploy(nouns.address, dotNouns.address);
  await contract.deployed();

  const result = await contract.main();
  await writeFile(`./cache/test5.svg`, result, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

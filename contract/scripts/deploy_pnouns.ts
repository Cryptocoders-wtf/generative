import { ethers, network } from "hardhat";
import { writeFile } from "fs";

const nounsDescriptor:string = (network.name == "goerli") ?
  "0x4d1e7066EEbA8F6c86033F3728C004E71328326D": 
  "0x0Cfdb3Ba1694c2bb2CFACB0339ad7b1Ae5932B63";
console.log("nounsDescriptor", nounsDescriptor);

async function main() {
  const factoryNouns = await ethers.getContractFactory("NounsAssetProvider");
  const nouns = await factoryNouns.deploy(nounsDescriptor);
  await nouns.deployed();
  console.log(`      provider="${nouns.address}"`);

  const factoryFont = await ethers.getContractFactory("LondrinaSolid");
  const font = await factoryFont.deploy();
  await font.deployed();

  const factory = await ethers.getContractFactory("PNounsPrivider");
  const contract = await factory.deploy(font.address, nouns.address);
  await contract.deployed();
  console.log(`      test3="${contract.address}"`);

  const result = await contract.generateSVGDocument(0);
  await writeFile(`./cache/pnouns1.svg`, result, ()=>{});  

  const result2 = await contract.generateSVGDocument(1233);
  await writeFile(`./cache/pnouns1234.svg`, result2, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

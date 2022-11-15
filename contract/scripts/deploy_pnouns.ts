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
  // await font.registerAll();
  console.log(`      font="${font.address}"`);

  const factory = await ethers.getContractFactory("PNounsPrivider");
  const contract = await factory.deploy(font.address, nouns.address);
  await contract.deployed();
  console.log(`      contract="${contract.address}"`);

  for (let i=0; i<3; i++) {
    const n = Math.pow(2,i);
    const result = await contract.generateSVGDocument(n);
    await writeFile(`./cache/pnouns${n}.svg`, result, ()=>{});
    console.log("output", n);  
  }

  const addresses = `export const addresses = {\n`
    + `  nounsProvider:"${nouns.address}",\n`
    + `  fontLondrinaSolid:"${font.address}",\n`
    + `  pnouns:"${contract.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/pnouns_${network.name}.ts`, addresses, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

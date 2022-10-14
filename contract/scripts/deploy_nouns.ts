import { ethers, network } from "hardhat";
import { writeFile } from "fs";

const nounsDescriptor:string = (network.name == "goerli") ?
  "0x4d1e7066EEbA8F6c86033F3728C004E71328326D": 
  "0x0Cfdb3Ba1694c2bb2CFACB0339ad7b1Ae5932B63";

console.log("nounsDescriptor", nounsDescriptor);

export const proxy = (network.name == "goerli") ?
    "0x3143867c145F73AF4E03a13DdCbdB555210e2027": // dummy proxy
    "0xa5409ec958c83c3f309868babaca7c86dcb077c1"; // openSea proxy

async function main() {
  const factory = await ethers.getContractFactory("NounsAssetProvider");
  const contractProvider = await factory.deploy(nounsDescriptor);
  await contractProvider.deployed();
  console.log(`      provider="${contractProvider.address}"`);

  const addresses = `export const addresses = {\n`
    + `  providerAddress:"${contractProvider.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/nouns_${network.name}.ts`, addresses, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

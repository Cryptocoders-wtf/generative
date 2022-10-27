import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses } from "../../src/utils/addresses";

const contractSchemes = addresses.colorSchemes[network.name];

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

  const factoryArt = await ethers.getContractFactory("MatrixProvider");
  const contractArt = await factoryArt.deploy(contractProvider.address, contractSchemes, 12, "nounsArt", "Nouns Art");
  await contractArt.deployed();
  console.log(`      bitcoinArt="${contractArt.address}"`);  

  const addresses = `export const addresses = {\n`
    + `  providerAddress:"${contractProvider.address}",\n`
    + `  nounsArt:"${contractArt.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/nouns_${network.name}.ts`, addresses, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

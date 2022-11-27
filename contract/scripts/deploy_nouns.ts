import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses as addresses2 } from "../../src/utils/addresses";

const contractSchemes = addresses2.colorSchemes[network.name];

import addresses from '@nouns/sdk/dist/contract/addresses.json';

const nounsDescriptor:string = (network.name == "goerli") ?
  addresses[5].nounsDescriptor: addresses[1].nounsDescriptor;
const nounsToken:string = (network.name == "goerli") ?
  addresses[5].nounsToken: addresses[1].nounsToken;

console.log("nounsDescriptor", nounsDescriptor);

export const proxy = (network.name == "goerli") ?
    "0x3143867c145F73AF4E03a13DdCbdB555210e2027": // dummy proxy
    "0xa5409ec958c83c3f309868babaca7c86dcb077c1"; // openSea proxy

async function main() {
  const factory = await ethers.getContractFactory("NounsAssetProvider");
  const contractProvider = await factory.deploy(nounsToken, nounsDescriptor);
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

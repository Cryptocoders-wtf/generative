import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses } from "../../src/utils/addresses";

const nounsProvider = addresses.nouns[network.name];
console.log("nounsProvider", nounsProvider);

async function main() {
  const factoryArt = await ethers.getContractFactory("DotNounsProvider");
  const contractArt = await factoryArt.deploy(nounsProvider);
  await contractArt.deployed();
  console.log(`      contractArt="${contractArt.address}"`);  

  const output = `export const addresses = {\n`
    + `  dotNounsArt:"${contractArt.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/dotNouns_${network.name}.ts`, output, ()=>{}); 

  console.log(`npx hardhat verify ${contractArt.address} ${nounsProvider} --network ${network.name}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses } from "../../src/utils/addresses";

const nounsProvider = addresses.nouns[network.name];
const tokengate = addresses.dynamic[network.name];
console.log("nounsProvider", nounsProvider, tokengate);

async function main() {
  const factoryArt = await ethers.getContractFactory("DotProvider");
  const contractArt = await factoryArt.deploy(nounsProvider);
  await contractArt.deployed();
  console.log(`      contractArt="${contractArt.address}"`);  

  const factoryToken = await ethers.getContractFactory("DotNounsToken");
  const token = await factoryToken.deploy(tokengate, contractArt.address);
  await token.deployed();
  console.log(`      token="${token.address}"`);

  const output = `export const addresses = {\n`
    + `  dotNounsArt:"${contractArt.address}",\n`
    + `  dotNounsToken:"${token.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/dotNouns_${network.name}.ts`, output, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

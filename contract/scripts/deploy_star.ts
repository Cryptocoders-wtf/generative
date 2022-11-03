import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses } from "../../src/utils/addresses";

async function main() {
  const factory = await ethers.getContractFactory("StarProvider");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      snow="${contract.address}"`);

  const result = await contract.generateSVGDocument(0);
  console.log("svg", result);
  await writeFile(`./cache/star.svg`, result, ()=>{});  

  /*
  const factoryArt = await ethers.getContractFactory("RepeatProvider");
  const contractArt = await factoryArt.deploy(contract.address, 2, "starart", "Star Art");
  await contractArt.deployed();
  console.log(`      snow_art="${contractArt.address}"`);
  */

  const addresses = `export const addresses = {\n`
    + `  starAddress:"${contract.address}",\n`
//    + `  starArtAddress:"${contractArt.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/star_${network.name}.ts`, addresses, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

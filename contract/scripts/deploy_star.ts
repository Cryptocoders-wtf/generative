import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses } from "../../src/utils/addresses";

const svgHelperAddress = addresses["svgHelper"][network.name];
console.log("svgHelperAddress", svgHelperAddress);

async function main() {
  const factory = await ethers.getContractFactory("StarProvider");
  const contract = await factory.deploy(svgHelperAddress);
  await contract.deployed();
  console.log(`      snow="${contract.address}"`);

  const result = await contract.generateSVGPart(0);
  console.log("svg", result.tag);

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

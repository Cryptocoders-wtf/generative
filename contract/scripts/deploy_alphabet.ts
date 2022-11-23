import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses } from "../../src/utils/addresses";

const font = addresses.londrina_solid[network.name];
const matrix = addresses.matrix[network.name];
const colors = addresses.colorSchemes[network.name];
console.log([font, matrix, colors]);

async function main() {
  const factory = await ethers.getContractFactory("AlphabetProvider");
  const contract = await factory.deploy(font, matrix, colors);
  await contract.deployed();
  console.log(`      alphabetProvider="${contract.address}"`);

  const result = await contract.generateSVGPart(0);
  console.log("svg", result);

  const addresses = `export const addresses = {\n`
    + `  alphabetProvider:"${contract.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/alphabet_${network.name}.ts`, addresses, ()=>{});
  console.log("Complete");  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

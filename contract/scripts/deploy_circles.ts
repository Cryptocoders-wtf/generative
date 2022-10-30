import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses } from "../../src/utils/addresses";

const contractSchemes = addresses.colorSchemes[network.name];
console.log("contractSchemes", contractSchemes);

const waitForUserInput = (text: string) => {
  return new Promise((resolve, reject) => {
    process.stdin.resume()
    process.stdout.write(text)
    process.stdin.once('data', data => resolve(data.toString().trim()))
  })
};

async function main() {
  const factoryGenerator = await ethers.getContractFactory("MatrixGenerator");
  const contractGenerator = await factoryGenerator.deploy();
  await contractGenerator.deployed();
  console.log(`      contractGenerator="${contractGenerator.address}"`);

  const factoryArt = await ethers.getContractFactory("CirclesProvider");
  const contractArt = await factoryArt.deploy(contractGenerator.address, contractSchemes);
  await contractArt.deployed();
  console.log(`      contractArt="${contractArt.address}"`);

  const addresses = `export const addresses = {\n`
    + `  matrixGenerator:"${contractGenerator.address}",\n`
    + `  contractArt:"${contractArt.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/circles_${network.name}.ts`, addresses, ()=>{});
  console.log("Complete");  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

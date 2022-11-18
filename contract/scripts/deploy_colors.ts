import { ethers, network } from "hardhat";
import { writeFile } from "fs";

const waitForUserInput = (text: string) => {
  return new Promise((resolve, reject) => {
    process.stdin.resume()
    process.stdout.write(text)
    process.stdin.once('data', data => resolve(data.toString().trim()))
  })
};

async function main() {
  // await waitForUserInput("Continue?");

  const factorySchemes = await ethers.getContractFactory("ColorSchemes");
  const contractSchemes = await factorySchemes.deploy();
  await contractSchemes.deployed();
  console.log(`      colorSchemes="${contractSchemes.address}"`);

  const addresses = `export const addresses = {\n`
    + `  colorSchemes:"${contractSchemes.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/colors_${network.name}.ts`, addresses, ()=>{});
  console.log("Complete");  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

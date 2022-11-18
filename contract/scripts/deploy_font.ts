import { ethers, network } from "hardhat";
import { writeFile } from "fs";

async function main() {
  const factory = await ethers.getContractFactory("LondrinaSolid");
  const font = await factory.deploy();
  await font.deployed();
  console.log(`      font="${font.address}"`);

  /*
  const result = await font.widthOf("a");
  console.log(result);
  */

  const addresses = `export const addresses = {\n`
    + `  font:"${font.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/londrina_solid_${network.name}.ts`, addresses, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

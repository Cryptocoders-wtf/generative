import { ethers, network } from "hardhat";
import { writeFile } from "fs";

async function main() {
  const factory = await ethers.getContractFactory("LondrinaSolid");
  const font = await factory.deploy();
  await font.deployed();

  const tx = await font.registerAll();
  const result = await tx.wait();
  console.log(result.gasUsed);
  
  /*
  const result = await font.widthOf("a");
  console.log(result);
  */

  console.log(`      font="${font.address}"`);

  const addresses = `export const addresses = {\n`
    + `  font:"${font.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/londrina_solid_${network.name}.ts`, addresses, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

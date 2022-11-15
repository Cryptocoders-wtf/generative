import { ethers, network } from "hardhat";
import { writeFile } from "fs";

async function main() {
  const factory = await ethers.getContractFactory("LondrinaSolid");
  const font = await factory.deploy();
  await font.deployed();

  /*
  const tx = await font.registerAll();
  const result = await tx.wait();
  console.log(result.gasUsed);
  */

  console.log(`      font="${font.address}"`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

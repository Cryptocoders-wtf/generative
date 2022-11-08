import { ethers, network } from "hardhat";
import { writeFile } from "fs";

async function main() {
  const factory = await ethers.getContractFactory("LondrinaSolid");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      font="${contract.address}"`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

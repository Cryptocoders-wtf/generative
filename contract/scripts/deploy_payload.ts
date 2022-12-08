import { ethers, network } from "hardhat";
import { writeFile } from "fs";

async function main() {
  const factory = await ethers.getContractFactory("Payload");
  const payload = await factory.deploy();
  console.log(`payload="${payload.address}"`);

  await payload.destroy();
  console.log("complete");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

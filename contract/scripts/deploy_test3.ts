import { ethers, network } from "hardhat";
import { writeFile } from "fs";

async function main() {
  const factory = await ethers.getContractFactory("SVGTest3");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      test3="${contract.address}"`);

  const result = await contract.main();
  await writeFile(`./cache/test3.svg`, result, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

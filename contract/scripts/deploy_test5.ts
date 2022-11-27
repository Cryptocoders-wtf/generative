import { ethers, network } from "hardhat";
import { writeFile } from "fs";

async function main() {

  const factory = await ethers.getContractFactory("SVGTest5Nouns");
  const contract = await factory.deploy();
  await contract.deployed();

  const result = await contract.main();
  await writeFile(`./cache/test5.svg`, result, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

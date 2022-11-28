import { ethers, network } from "hardhat";
import { writeFile } from "fs";

async function main() {
  const factory = await ethers.getContractFactory("SVGTest6Dot");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      test="${contract.address}"`);

  const result = await contract.main();
  await writeFile(`./cache/test6.svg`, result, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

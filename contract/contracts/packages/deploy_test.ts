import { ethers, network } from "hardhat";
import { writeFile } from "fs";

async function main() {
  const factory = await ethers.getContractFactory("SVGTest");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      test="${contract.address}"`);

  const result = await contract.main();
  await writeFile(`../../../cache/test.svg`, result, ()=>{});  

  const result2 = await contract.main2();
  await writeFile(`../../../cache/test2.svg`, result2, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

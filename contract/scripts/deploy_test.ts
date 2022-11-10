import { ethers, network } from "hardhat";
import { writeFile } from "fs";

async function main() {
  const factory = await ethers.getContractFactory("SVGTest");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      test="${contract.address}"`);

  const result = await contract.main();
  await writeFile(`../../../cache/test.svg`, result, ()=>{});  

  const factory2 = await ethers.getContractFactory("SVGTest2");
  const contract2 = await factory2.deploy();
  await contract2.deployed();
  console.log(`      test2="${contract2.address}"`);

  const fontAddress = await contract2.font();
  console.log("font", fontAddress);

  const result2 = await contract2.main();
  await writeFile(`./cache/test2.svg`, result2, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

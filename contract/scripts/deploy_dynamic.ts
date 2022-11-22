import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses } from "../../src/utils/addresses";

const splatterToken = addresses.splatterToken[network.name];

async function main() {
  const [owner] = await ethers.getSigners();
  const factory = await ethers.getContractFactory("DynamicTokenGate");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      tokenGate="${contract.address}"`);

  const result2 = await contract.balanceOf(owner.address);
  console.log("result2", result2);
  const result3 = await contract.balanceOf("0x4E4cD175f812f1Ba784a69C1f8AC8dAa52AD7e2B");
  console.log("result3", result3);

  const tx = await contract.append(splatterToken);
  await tx.wait();

  const result4 = await contract.balanceOf(owner.address);
  console.log("result4", result2);
  const result5 = await contract.balanceOf("0x4E4cD175f812f1Ba784a69C1f8AC8dAa52AD7e2B");
  console.log("result5", result3);

  const addresses = `export const addresses = {\n`
    + `  tokenGate:"${contract.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/dynamic_${network.name}.ts`, addresses, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

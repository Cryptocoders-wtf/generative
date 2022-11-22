import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses } from "../../src/utils/addresses";

const splatterTokenAddress = addresses.splatterToken[network.name];

async function main() {
  let result;
  const [owner] = await ethers.getSigners();
  console.log("owner", owner.address);

  const splatterFactory = await ethers.getContractFactory("SplatterToken");
  const splatterToken = await splatterFactory.attach(splatterTokenAddress);

  result = await splatterToken.balanceOf(owner.address);
  console.log("splatter owner", result);
  result = await splatterToken.balanceOf("0x4E4cD175f812f1Ba784a69C1f8AC8dAa52AD7e2B");
  console.log("splatter user1", result);

  if (false) {
    return;
  }

  const factory = await ethers.getContractFactory("DynamicTokenGate");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      tokenGate="${contract.address}"`);

  result = await contract.balanceOf(owner.address);
  console.log("result2", result);
  result = await contract.balanceOf("0x4E4cD175f812f1Ba784a69C1f8AC8dAa52AD7e2B");
  console.log("result3", result);

  const tx = await contract.append(splatterTokenAddress);
  await tx.wait();

  result = await contract.balanceOf(owner.address);
  console.log("result4", result);
  result = await contract.balanceOf("0x4E4cD175f812f1Ba784a69C1f8AC8dAa52AD7e2B");
  console.log("result5", result);

  const addresses = `export const addresses = {\n`
    + `  tokenGate:"${contract.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/dynamic_${network.name}.ts`, addresses, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { whitelistTokens } from "../../src/utils/assetTokens";

const whitelist = whitelistTokens[network.name];
console.log("whitelist", whitelist);


async function main() {
  const [owner] = await ethers.getSigners();
  const factory = await ethers.getContractFactory("AssetTokenGate");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      tokenGate="${contract.address}"`);

  const tx = await contract.setWhitelist(whitelist);
  await tx.wait();

  const result2 = await contract.hasWhitelistToken(owner.address);
  console.log("result2", result2);
  const result3 = await contract.hasWhitelistToken("0xf05a0497994a33f18aa378630BC674eFC77Ad557");
  console.log("result3", result3);

  const addresses = `export const addresses = {\n`
    + `  tokenGate:"${contract.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/tokenGate_${network.name}.ts`, addresses, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

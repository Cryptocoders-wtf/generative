import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses } from "../../src/utils/addresses";

const dotNouns = addresses.dotNouns[network.name];
const tokengate = addresses.dynamic[network.name];
console.log("nounsProvider", dotNouns, tokengate);
const designer = "0x14aea32f6e6dcaecfa1bc62776b2e279db09255d";

async function main() {

  const factoryToken = await ethers.getContractFactory("DotNounsToken");
  const token = await factoryToken.deploy(tokengate, dotNouns, designer);
  await token.deployed();
  console.log(`      token="${token.address}"`);

  const result = await token.totalSupply();
  console.log("totalSupply", result.toNumber());
  const result2 = await token.mintLimit();
  console.log("mintLimit", result2.toNumber());
  const [owner] = await ethers.getSigners();
  console.log("owner", owner.address, tokengate);
  const result3 = await token.balanceOf("0x4F1CA5Ac1ab5e119b2C8F015cDC53e618ae9559a");
  console.log("balanceOf", result3.toNumber());

  const dynamicFactory = await ethers.getContractFactory("DynamicTokenGate");
  const dynamic = dynamicFactory.attach(tokengate);
  const result4 = await dynamic.balanceOf("0x4F1CA5Ac1ab5e119b2C8F015cDC53e618ae9559a");
  console.log("dynamic", result4.toNumber());

  const result5 = await token.mintPriceFor(owner.address);
  console.log("mintPriceFor", result5 );

  const output = `export const addresses = {\n`
    + `  dotNounsToken:"${token.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/dotNounsToken_${network.name}.ts`, output, ()=>{});

  console.log(`npx hardhat verify ${token.address} ${tokengate} ${dotNouns} ${designer} --network ${network.name}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses } from "../../src/utils/addresses";

const alphabet = addresses.alphabet[network.name];
const tokengate = addresses.dynamic[network.name];
export const proxy = (network.name == "goerli") ?
    "0x3143867c145F73AF4E03a13DdCbdB555210e2027": // dummy proxy
    "0xa5409ec958c83c3f309868babaca7c86dcb077c1"; // openSea proxy

console.log("alphabet", alphabet);
console.log("tokengate", tokengate);
console.log("proxyAddress", proxy);

const waitForUserInput = (text: string) => {
  return new Promise((resolve, reject) => {
    process.stdin.resume()
    process.stdout.write(text)
    process.stdin.once('data', data => resolve(data.toString().trim()))
  })
};

async function main() {
  const factoryToken = await ethers.getContractFactory("AlphabetToken");
  const token = await factoryToken.deploy(tokengate, alphabet, proxy);
  await token.deployed();
  console.log(`      token="${token.address}"`);

  const addresses = `export const addresses = {\n`
    + `  alphatoken:"${token.address}"\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/alphatoken_${network.name}.ts`, addresses, ()=>{});
  console.log("Complete");  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

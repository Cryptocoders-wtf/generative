import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses } from "../../src/utils/addresses";

const svgHelperAddress = addresses["svgHelper"][network.name];
console.log("svgHelperAddress", svgHelperAddress);

export const developer = "0x6a615Ca8D7053c0A0De2d11CACB6f321CA63BD62"; // sn2
export const proxy = (network.name == "rinkeby") ?
    "0xf57b2c51ded3a29e6891aba85459d600256cf317":
    "0xa5409ec958c83c3f309868babaca7c86dcb077c1"; // openSea proxy

async function main() {
  const factory = await ethers.getContractFactory("SnowProvider");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      snow="${contract.address}"`);

  const result = await contract.generateSVGPart(0);
  console.log("svg", result.tag);

  const factoryArt = await ethers.getContractFactory("MultiplexProvider");
  const contractArt = await factoryArt.deploy(contract.address, "snowart", "Snow Art");
  await contractArt.deployed();
  console.log(`      snow_art="${contractArt.address}"`);

  /*
  const factoryToken = await ethers.getContractFactory("SplatterToken");
  const token = await factoryToken.deploy(contractArt.address, developer, proxy);
  await token.deployed();
  console.log(`      token="${token.address}"`);
  */

  const addresses = `export const addresses = {\n`
    + `  snowAddress:"${contract.address}",\n`
    + `  snowArtAddress:"${contractArt.address}",\n`
//    + `  splatterToken:"${token.address}"\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/snow_${network.name}.ts`, addresses, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

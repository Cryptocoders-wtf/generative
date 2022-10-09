import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses } from "../../src/utils/addresses";

export const developer = "0x6a615Ca8D7053c0A0De2d11CACB6f321CA63BD62"; // sn2
export const proxy = (network.name == "rinkeby") ?
    "0xf57b2c51ded3a29e6891aba85459d600256cf317":
    "0xa5409ec958c83c3f309868babaca7c86dcb077c1"; // openSea proxy

const tokenGateAddress = addresses["tokenGate"][network.name];
console.log("tokenGateAddress", tokenGateAddress);

async function main() {
  const factoryHelper = await ethers.getContractFactory("SVGHelperA");
  const contractHelper = await factoryHelper.deploy();
  await contractHelper.deployed();
  console.log(`      helper="${contractHelper.address}"`);

  const factory = await ethers.getContractFactory("SplatterProvider");
  const contract = await factory.deploy(contractHelper.address);
  await contract.deployed();
  console.log(`      splatter="${contract.address}"`);

  const result = await contractHelper.functions.generateSVGPart(contract.address, 1);
  console.log("svg", result.tag, result.gas.toNumber());
  
  const factoryArt = await ethers.getContractFactory("MultiplexProvider");
  const contractArt = await factoryArt.deploy(contract.address, "spltart", "Splatter Art");
  await contractArt.deployed();
  console.log(`      splatter_art="${contractArt.address}"`);

  const factoryToken = await ethers.getContractFactory("SplatterToken");
  const token = await factoryToken.deploy(contractArt.address, proxy);
  await token.deployed();
  console.log(`      token="${token.address}"`);

  const addresses = `export const addresses = {\n`
    + `  svgHelperAddress:"${contractHelper.address}",\n`
    + `  splatterAddress:"${contract.address}",\n`
    + `  splatterArtAddress:"${contractArt.address}",\n`
    + `  splatterToken:"${token.address}"\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/splatter_${network.name}.ts`, addresses, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

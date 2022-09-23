import { ethers, network } from "hardhat";
import { writeFile } from "fs";

async function main() {
  const factory = await ethers.getContractFactory("SplatterProvider");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      splatter="${contract.address}"`);

  const factoryArt = await ethers.getContractFactory("SplatterArtProvider");
  const contractArt = await factoryArt.deploy(contract.address);
  await contractArt.deployed();
  console.log(`      splatter_art="${contractArt.address}"`);

  const addresses = `export const addresses = {\n`
    + `  splatterAddress:"${contract.address}",\n`
    + `  splatterArtAddress:"${contractArt.address}"\n`
    + `}\n`;
  await writeFile(`./cache/splatter_${network.name}.ts`, addresses, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

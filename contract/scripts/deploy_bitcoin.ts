import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import { addresses } from "../../src/utils/addresses";

const assetStoreAddress = addresses.assetStore[network.name];
console.log("assetStoreAddress", assetStoreAddress);

async function main() {
  const factory = await ethers.getContractFactory("AssetStoreProvider");
  const contract = await factory.deploy(assetStoreAddress);
  await contract.deployed();
  console.log(`      assetStoreProvider="${contract.address}"`);

  const result = await contract.generateSVGPart(81);
  console.log("svg", result);

  const factoryArt = await ethers.getContractFactory("RepeatProvider");
  const contractArt = await factoryArt.deploy(contract.address, "currency", "On-chain Currency");
  await contractArt.deployed();
  console.log(`      bitcoinArt="${contractArt.address}"`);

  const addresses = `export const addresses = {\n`
    + `  assetStoreProvider:"${contract.address}",\n`
    + `  bitcoinArtProvider:"${contractArt.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/bitcoin_${network.name}.ts`, addresses, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

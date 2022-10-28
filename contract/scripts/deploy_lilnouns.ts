import { ethers, network } from "hardhat";
import { writeFile } from "fs";

const nounsDescriptor:string = (network.name == "goerli") ?
  "0x745a415Eb426388D9Fe925EF9DcB1cEf42885f13": 
  "0x11fb55d9580cdbfb83de3510ff5ba74309800ad1";

console.log("nounsDescriptor", nounsDescriptor);

async function main() {
  const factory = await ethers.getContractFactory("NounsAssetProvider");
  const contractProvider = await factory.deploy(nounsDescriptor);
  await contractProvider.deployed();
  console.log(`      provider="${contractProvider.address}"`);

  const factoryArt = await ethers.getContractFactory("DotProvider");
  const contractArt = await factoryArt.deploy(contractProvider.address);
  await contractArt.deployed();
  console.log(`      contractArt="${contractArt.address}"`);  

  const output = `export const addresses = {\n`
  + `  providerAddress:"${contractProvider.address}",\n`
  + `  dotNounsArt:"${contractArt.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/lilnouns_${network.name}.ts`, output, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import addresses from '@nouns/sdk/dist/contract/addresses.json';
import { addresses as addresses2 } from "../../src/utils/addresses";

const nounsProvider = addresses2.nouns[network.name];
const lonrinaFont = addresses2.londrina_solid[network.name];

const designer = "0x14aea32f6e6dcaecfa1bc62776b2e279db09255d";

async function main() {
  const factory = await ethers.getContractFactory("PNounsPrivider");
  const contract = await factory.deploy(lonrinaFont, nounsProvider);
  await contract.deployed();
  console.log(`      contract="${contract.address}"`);

  for (let i=0; i<11; i++) {
    const n = Math.pow(2,i);
    const result = await contract.generateSVGDocument(n);
    await writeFile(`./cache/pnouns${n}.svg`, result, ()=>{});
    console.log("output", n);  
  }

  const addresses = `export const addresses = {\n`
    + `  pnouns:"${contract.address}",\n`
    + `}\n`;
  await writeFile(`../src/utils/addresses/pnouns_${network.name}.ts`, addresses, ()=>{});
  
  console.log(`npx hardhat verify ${contract.address} ${lonrinaFont} ${nounsProvider} --network ${network.name}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

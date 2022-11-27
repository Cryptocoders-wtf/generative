import { ethers, network } from "hardhat";
import { writeFile } from "fs";
import addresses from '@nouns/sdk/dist/contract/addresses.json';

const nounsDescriptor:string = (network.name == "goerli") ?
  addresses[5].nounsDescriptor: addresses[1].nounsDescriptor;
const nounsToken:string = (network.name == "goerli") ?
  addresses[5].nounsToken: addresses[1].nounsToken;
console.log("nounsDescriptor", nounsDescriptor);

async function main() {
  const factoryNouns = await ethers.getContractFactory("NounsAssetProvider");
  const nouns = await factoryNouns.deploy(nounsToken, nounsDescriptor);
  await nouns.deployed();
  console.log(`      provider="${nouns.address}"`);

  // const foo = await nouns.generateSVGPart(0);
  // console.log(foo);

  const factory = await ethers.getContractFactory("SVGTest3");
  const contract = await factory.deploy(nouns.address);
  await contract.deployed();
  console.log(`      test3="${contract.address}"`);

  const result = await contract.main();
  await writeFile(`./cache/test3.svg`, result, ()=>{});  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

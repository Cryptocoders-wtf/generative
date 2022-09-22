import { ethers, network } from "hardhat";

async function main() {
  const factory = await ethers.getContractFactory("SplatterProvider");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      splatter="${contract.address}"`);

  const factoryArt = await ethers.getContractFactory("SplatterArtProvider");
  const contractArt = await factoryArt.deploy(contract.address);
  await contractArt.deployed();
  console.log(`      splatter_art="${contractArt.address}"`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

import { ethers } from 'hardhat';

async function main() {
  const factory = await ethers.getContractFactory('DummyProxy');
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      proxy="${contract.address}"`);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

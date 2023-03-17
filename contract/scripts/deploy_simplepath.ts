import { ethers } from 'hardhat';

async function main() {
  const factory = await ethers.getContractFactory('SimplePathToken');
  const contract = await factory.deploy("SimplePathToken", "Path");
  await contract.deployed();
  console.log(`      simple="${contract.address}"`);
  
  await contract.mint();
  await contract.mint();
  await contract.mint();
  await contract.mint();

  const res = await contract.tokenURI(1);
  console.log(res);
  const res2 = await contract.debugGenerateSVG(1);
  console.log(res2);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

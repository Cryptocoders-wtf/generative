import { ethers, network } from 'hardhat';
import { writeFile } from 'fs';
import { addresses } from '../../src/utils/addresses';

async function main() {
  const factory = await ethers.getContractFactory('SimpleVectorToken');
  const contract = await factory.deploy("SimpleVectorToken", "Vector");
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

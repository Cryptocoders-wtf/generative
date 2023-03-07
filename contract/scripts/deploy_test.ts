import { ethers, network } from 'hardhat';
import { writeFile } from 'fs';

async function main() {
  const factory = await ethers.getContractFactory('SVGTest');
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      test="${contract.address}"`);

  const result = await contract.main();
  await writeFile(`./cache/test.svg`, result, () => {});
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

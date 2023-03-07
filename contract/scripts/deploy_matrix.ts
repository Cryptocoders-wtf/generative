import { ethers, network } from 'hardhat';
import { writeFile } from 'fs';

async function main() {
  const factory = await ethers.getContractFactory('MatrixGenerator');
  const matrix = await factory.deploy();
  await matrix.deployed();
  console.log(`      matrix="${matrix.address}"`);

  const addresses = `export const addresses = {\n` + `  matrix:"${matrix.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/matrix_${network.name}.ts`, addresses, () => {});
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

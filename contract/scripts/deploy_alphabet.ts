import { ethers, network } from 'hardhat';
import { writeFile } from 'fs';
import { addresses } from '../../src/utils/addresses';

const font = addresses.londrina_solid[network.name];
const matrix = addresses.matrix[network.name];
const colors = addresses.colorSchemes[network.name];
console.log([font, matrix, colors]);

async function main() {
  const factoryWallet = await ethers.getContractFactory('OnChainWallet');
  const wallet = await factoryWallet.deploy();
  console.log(`      wallet="${wallet.address}"`);
  await wallet.deployed();

  const factory = await ethers.getContractFactory('AlphabetProvider');
  const contract = await factory.deploy(font, matrix, colors, wallet.address);
  await contract.deployed();
  console.log(`      alphabetProvider="${contract.address}"`);

  const result = await contract.generateSVGPart(0);
  console.log('svg', result);

  console.log(
    `npx hardhat verify ${contract.address} ${font} ${matrix} ${colors} ${wallet.address} --network ${network.name}`,
  );

  const addresses =
    `export const addresses = {\n` +
    `  wallet:"${wallet.address}",\n` +
    `  alphabetProvider:"${contract.address}",\n` +
    `}\n`;
  await writeFile(`../src/utils/addresses/alphabet_${network.name}.ts`, addresses, () => {});
  console.log('Complete');
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

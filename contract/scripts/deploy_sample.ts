import { ethers, network } from 'hardhat';
import { writeFile } from 'fs';
import { addresses } from '../../src/utils/addresses';

const svgHelperAddress = addresses['svgHelper'][network.name];
console.log('svgHelperAddress', svgHelperAddress);

export const proxy =
  network.name == 'goerli'
    ? '0x3143867c145F73AF4E03a13DdCbdB555210e2027' // dummy proxy
    : '0xa5409ec958c83c3f309868babaca7c86dcb077c1'; // openSea proxy

async function main() {
  const factory = await ethers.getContractFactory('SplatterProvider');
  const contractProvider = await factory.deploy(svgHelperAddress);
  await contractProvider.deployed();
  console.log(`      provider="${contractProvider.address}"`);

  const factoryToken = await ethers.getContractFactory('SampleToken');
  const token = await factoryToken.deploy(contractProvider.address, proxy);
  await token.deployed();
  console.log(`      token="${token.address}"`);

  const addresses =
    `export const addresses = {\n` +
    `  providerAddress:"${contractProvider.address}",\n` +
    `  sampleToken:"${token.address}"\n` +
    `}\n`;
  await writeFile(`../src/utils/addresses/sample_${network.name}.ts`, addresses, () => {});
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

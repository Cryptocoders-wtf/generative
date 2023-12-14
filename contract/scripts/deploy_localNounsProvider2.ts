// LocalNounsTokenとLocalNounsProviderのみデプロイ
import { ethers, network } from 'hardhat';
import { writeFile } from 'fs';
import { addresses } from '../../src/utils/addresses';

const nounsDescriptor = addresses.nounsDescriptor[network.name];
const localNounsDescriptor = addresses.localNounsDescriptor[network.name];
const localNounsMinter = addresses.localNounsMinter[network.name];

async function main() {

  const factoryProvider = await ethers.getContractFactory('LocalNounsProvider2');
  const provider = await factoryProvider.deploy(nounsDescriptor, localNounsDescriptor);
  await provider.deployed();
  console.log(`##LocalNounsProvider="${provider.address}"`);
  await runCommand(`npx hardhat verify ${provider.address} ${nounsDescriptor} ${localNounsDescriptor} --network ${network.name} &`);

  const addresses3 = `export const addresses = {\n` + `  localNounsProvider:"${provider.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/localNounsProvider_${network.name}.ts`, addresses3, () => { });

  
  const factoryToken = await ethers.getContractFactory('LocalNounsToken');
  const token = await factoryToken.deploy(provider.address, localNounsMinter);
  await token.deployed();
  console.log(`##LocalNounsToken="${token.address}"`);
  await runCommand(`npx hardhat verify ${token.address} ${provider.address} ${localNounsMinter} --network ${network.name} &`);

  const addresses4 = `export const addresses = {\n` + `  localNounsToken:"${token.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/localNounsToken_${network.name}.ts`, addresses4, () => { });

}

async function runCommand(command: string) {
  if (network.name !== 'localhost') {
    console.log(command);
  }
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
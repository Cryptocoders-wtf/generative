// LocalNounsTokenとLocalNounsProviderのみデプロイ
import { ethers, network } from 'hardhat';
import { writeFile } from 'fs';
import { addresses } from '../../src/utils/addresses';

const nounsDescriptor = addresses.nounsDescriptor[network.name];
const localNounsDescriptor = addresses.localNounsDescriptor[network.name];
const localNounsMinterAddress = addresses.localNounsMinter[network.name];
const tokenGateAddress = addresses.tokenGate[network.name];

async function main() {

  const factoryProvider = await ethers.getContractFactory('LocalNounsProvider2');
  const provider = await factoryProvider.deploy(nounsDescriptor, localNounsDescriptor);
  await provider.deployed();
  console.log(`##LocalNounsProvider="${provider.address}"`);
  await runCommand(`npx hardhat verify ${provider.address} ${nounsDescriptor} ${localNounsDescriptor} --network ${network.name} &`);

  const addresses3 = `export const addresses = {\n` + `  localNounsProvider:"${provider.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/localNounsProvider_${network.name}.ts`, addresses3, () => { });

  
  const factoryToken = await ethers.getContractFactory('LocalNounsToken');
  const token = await factoryToken.deploy(provider.address, localNounsMinterAddress);
  await token.deployed();
  console.log(`##LocalNounsToken="${token.address}"`);
  await runCommand(`npx hardhat verify ${token.address} ${provider.address} ${localNounsMinterAddress} --network ${network.name} &`);

  const addresses4 = `export const addresses = {\n` + `  localNounsToken:"${token.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/localNounsToken_${network.name}.ts`, addresses4, () => { });

  const factoryMinter = await ethers.getContractFactory('LocalNounsMinter');
  const minterContract = await factoryMinter.deploy(token.address, tokenGateAddress);
  await minterContract.deployed();
  console.log(`##LocalNounsMinter="${minterContract.address}"`);
  await runCommand(`npx hardhat verify ${minterContract.address} ${token.address} ${tokenGateAddress} --network ${network.name} &`);

  const addresses5 = `export const addresses = {\n` + `  localNounsMinter:"${minterContract.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/localNounsMinter_${network.name}.ts`, addresses5, () => { });

  await token.setMinter(minterContract.address);


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
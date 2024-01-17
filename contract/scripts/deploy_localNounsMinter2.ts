// LocalNounsTokenとLocalNounsProviderのみデプロイ
import { ethers, network } from 'hardhat';
import { writeFile } from 'fs';
import { addresses } from '../../src/utils/addresses';

const localNounsTokenAddress = addresses.localNounsToken[network.name];
const tokenGateAddress = addresses.tokenGate[network.name];

async function main() {

  const factoryMinter = await ethers.getContractFactory('LocalNounsMinter2');
  const minterContract = await factoryMinter.deploy(localNounsTokenAddress, tokenGateAddress);
  await minterContract.deployed();
  console.log(`##LocalNounsMinter="${minterContract.address}"`);
  await runCommand(`npx hardhat verify ${minterContract.address} ${localNounsTokenAddress} ${tokenGateAddress} --network ${network.name} &`);

  const addresses5 = `export const addresses = {\n` + `  localNounsMinter:"${minterContract.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/localNounsMinter_${network.name}.ts`, addresses5, () => { });

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
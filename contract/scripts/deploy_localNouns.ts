import { ethers, network } from 'hardhat';
import { exec } from 'child_process';
import { writeFile } from 'fs';
import { addresses } from '../../src/utils/addresses';

const nounsDescriptor = addresses.nounsDescriptor[network.name];
const nftDescriptor = addresses.nftDescriptor[network.name];

async function main() {

  const [minter] = await ethers.getSigners();
  console.log(`##minter="${minter.address}"`);

  const factoryTokenGate = await ethers.getContractFactory('AssetTokenGate');
  const tokenGate = await factoryTokenGate.deploy();
  await tokenGate.deployed();
  console.log(`##tokenGate="${tokenGate.address}"`);
  await runCommand(`npx hardhat verify ${tokenGate.address} --network ${network.name} &`);
  const addresses0 = `export const addresses = {\n` + `  tokenGate:"${tokenGate.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/tokenGate_${network.name}.ts`, addresses0, () => { });

  const factoryLocalNounsDescriptor = await ethers.getContractFactory('LocalNounsDescriptor', {
    libraries: {
      NFTDescriptor: nftDescriptor,
    }
  });
  const localNounsDescriptor = await factoryLocalNounsDescriptor.deploy(
    nounsDescriptor
  );
  await localNounsDescriptor.deployed();
  console.log(`##localNounsDescriptor="${localNounsDescriptor.address}"`);
  await runCommand(`npx hardhat verify ${localNounsDescriptor.address} ${nounsDescriptor} --network ${network.name} &`);

  const addresses2 = `export const addresses = {\n` + `  localNounsDescriptor:"${localNounsDescriptor.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/localNounsDescriptor_${network.name}.ts`, addresses2, () => { });


  const factoryProvider = await ethers.getContractFactory('LocalNounsProvider2');
  const provider = await factoryProvider.deploy(nounsDescriptor, localNounsDescriptor.address);
  await provider.deployed();
  console.log(`##LocalNounsProvider="${provider.address}"`);
  await runCommand(`npx hardhat verify ${provider.address} ${nounsDescriptor} ${localNounsDescriptor.address} --network ${network.name} &`);

  const addresses3 = `export const addresses = {\n` + `  localNounsProvider:"${provider.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/localNounsProvider_${network.name}.ts`, addresses3, () => { });

  const factoryToken = await ethers.getContractFactory('LocalNounsToken');
  const token = await factoryToken.deploy(provider.address, minter.address);
  await token.deployed();
  console.log(`##LocalNounsToken="${token.address}"`);
  await runCommand(`npx hardhat verify ${token.address} ${provider.address} ${minter.address} --network ${network.name} &`);

  const addresses4 = `export const addresses = {\n` + `  localNounsToken:"${token.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/localNounsToken_${network.name}.ts`, addresses4, () => { });

  const factoryMinter = await ethers.getContractFactory('LocalNounsMinter');
  const minterContract = await factoryMinter.deploy(token.address, tokenGate.address);
  await minterContract.deployed();
  console.log(`##LocalNounsMinter="${minterContract.address}"`);
  await runCommand(`npx hardhat verify ${minterContract.address} ${token.address} ${tokenGate.address} --network ${network.name} &`);

  const addresses5 = `export const addresses = {\n` + `  localNounsMinter:"${minterContract.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/localNounsMinter_${network.name}.ts`, addresses5, () => { });

  await token.setMinter(minterContract.address);

}

async function runCommand(command: string) {
  if (network.name !== 'localhost') {
    console.log(command);
  }
  // なぜかコマンドが終了しないので手動で実行
  // await exec(command, (error, stdout, stderr) => {
  //     if (error) {
  //         console.log(`error: ${error.message}`);
  //         return;
  //     }
  //     if (stderr) {
  //         console.log(`stderr: ${stderr}`);
  //         return;
  //     }
  //     console.log(`stdout: ${stdout}`);
  // });
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
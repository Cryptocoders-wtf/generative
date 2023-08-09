import { ethers, network } from 'hardhat';
import { exec } from 'child_process';
import { writeFile } from 'fs';
import { addresses } from '../../src/utils/addresses';

const nounsDescriptor = addresses.nounsDescriptor[network.name];
const nounsSeeder = addresses.nounsSeeder[network.name];
const nftDescriptor = addresses.nftDescriptor[network.name];

const committee = "0x52A76a606AC925f7113B4CC8605Fe6bCad431EbB";
// const committee = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"; // localhost

async function main() {

  const factorySeeder = await ethers.getContractFactory('LocalNounsSeeder');
  const localseeder = await factorySeeder.deploy();
  await localseeder.deployed();
  console.log(`##localseeder="${localseeder.address}"`);
  await runCommand(`npx hardhat verify ${localseeder.address} --network ${network.name} &`);

  const addresses = `export const addresses = {\n` + `  localseeder:"${localseeder.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/localseeder_${network.name}.ts`, addresses, () => {});


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
  await writeFile(`../src/utils/addresses/localNounsDescriptor_${network.name}.ts`, addresses2, () => {});


  const factorySVGStore = await ethers.getContractFactory('LocalNounsProvider');
  const provider = await factorySVGStore.deploy(nounsDescriptor, localNounsDescriptor.address, nounsSeeder, localseeder.address);
  await provider.deployed();
  console.log(`##LocalNounsProvider="${provider.address}"`);
  await runCommand(`npx hardhat verify ${provider.address} ${nounsDescriptor} ${localNounsDescriptor.address} ${nounsSeeder} ${localseeder.address} --network ${network.name} &`);

  const addresses3 = `export const addresses = {\n` + `  localNounsProvider:"${provider.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/localNounsProvider_${network.name}.ts`, addresses3, () => {});
  

  const factoryToken = await ethers.getContractFactory('LocalNounsToken');
  const token = await factoryToken.deploy(provider.address, committee, committee, committee);
  await token.deployed();
  console.log(`##LocalNounsToken="${token.address}"`);
  await runCommand(`npx hardhat verify ${token.address} ${provider.address} ${committee} ${committee} ${committee} --network ${network.name} &`);

  const addresses4 = `export const addresses = {\n` + `  localNounsToken:"${token.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/localNounsToken${network.name}.ts`, addresses4, () => {});

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
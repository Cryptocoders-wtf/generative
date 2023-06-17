import { ethers, network } from 'hardhat';
import { exec } from 'child_process';
import addresses from '@nouns/sdk/dist/contract/addresses.json';

// const nounsDescriptor: string = network.name == 'goerli' ? addresses[5].nounsDescriptor : addresses[1].nounsDescriptor;
// const nounsSeeder: string = network.name == 'goerli' ? addresses[5].nounsSeeder : addresses[1].nounsSeeder;
// const nftDescriptor: string = network.name == 'goerli' ? addresses[5].nftDescriptor : addresses[1].nftDescriptor;

const nounsDescriptor: string = '0xA6f003aa2E8b8EbAe9e3b7792719A08Ea8683107'; // mumbai
const nounsSeeder: string = '0x5f5C984E0BAf150D5a74ae21f4777Fd1947DE8c9'; // mumbai
const nftDescriptor: string = '0xC93218fF7C44cbEB57c7661DCa886deCBc0E07C0'; // mumbai

// const nounsDescriptor: string = '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0'; // localhost
// const nounsSeeder: string = '0x5FC8d32690cc91D4c39d9d3abcBD16989F875707'; // localhost
// const nftDescriptor: string = '0x5FbDB2315678afecb367f032d93F642f64180aa3'; // localhost

const committee = "0x52A76a606AC925f7113B4CC8605Fe6bCad431EbB";
// const committee = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"; // localhost

async function main() {

  const factorySeeder = await ethers.getContractFactory('LocalNounsSeeder');
  const localseeder = await factorySeeder.deploy();
  await localseeder.deployed();
  console.log(`##localseeder="${localseeder.address}"`);
  await runCommand(`npx hardhat verify ${localseeder.address} --network ${network.name} &`);

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

  const factorySVGStore = await ethers.getContractFactory('LocalNounsProvider');
  const provider = await factorySVGStore.deploy(nounsDescriptor, localNounsDescriptor.address, nounsSeeder, localseeder.address);
  await provider.deployed();
  console.log(`##LocalNounsProvider="${provider.address}"`);
  await runCommand(`npx hardhat verify ${provider.address} ${nounsDescriptor} ${localNounsDescriptor.address} ${nounsSeeder} ${localseeder.address} --network ${network.name} &`);

  const factoryToken = await ethers.getContractFactory('LocalNounsToken');
  const token = await factoryToken.deploy(provider.address, committee, committee, committee);
  await token.deployed();
  console.log(`##LocalNounsToken="${token.address}"`);
  await runCommand(`npx hardhat verify ${token.address} ${provider.address} ${committee} ${committee} ${committee} --network ${network.name} &`);

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
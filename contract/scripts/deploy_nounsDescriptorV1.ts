import { ethers, network } from 'hardhat';
import { exec } from 'child_process';
import addresses from '@nouns/sdk/dist/contract/addresses.json';
import { writeFile } from 'fs';

// const nftDescriptor: string = network.name == 'goerli' ? addresses[5].nftDescriptor : addresses[1].nftDescriptor;
// const nftDescriptor: string = '0x1881c541E9d83880008B3720de0E537C34052ecf'; // mumbai
// const nftDescriptor: string = '0x5FbDB2315678afecb367f032d93F642f64180aa3'; // localhost


async function main() {

  const factoryNounsSeeder = await ethers.getContractFactory('NounsSeeder');
  const nounsSeeder = await factoryNounsSeeder.deploy();
  await nounsSeeder.deployed();
  console.log(`##nounsSeeder="${nounsSeeder.address}"`);
  await runCommand(`npx hardhat verify ${nounsSeeder.address} --network ${network.name} &`);

  const addresses = `export const addresses = {\n` + `  nounsSeeder:"${nounsSeeder.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/nounsSeeder_${network.name}.ts`, addresses, () => { });

  const factoryNFTDescriptor = await ethers.getContractFactory('NFTDescriptor');
  const nftDescriptor = await factoryNFTDescriptor.deploy();
  await nftDescriptor.deployed();
  console.log(`##nftDescriptor="${nftDescriptor.address}"`);
  await runCommand(`npx hardhat verify ${nftDescriptor.address} --network ${network.name} &`);

  const addresses2 = `export const addresses = {\n` + `  nftDescriptor:"${nftDescriptor.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/nftDescriptor_${network.name}.ts`, addresses2, () => { });

  const factoryNounsDescriptor = await ethers.getContractFactory('NounsDescriptor', {
    libraries: {
      NFTDescriptor: nftDescriptor.address,
    }
  });
  const nounsDescriptor = await factoryNounsDescriptor.deploy();
  await nounsDescriptor.deployed();
  console.log(`##nounsDescriptor="${nounsDescriptor.address}"`);
  await runCommand(`npx hardhat verify ${nounsDescriptor.address} --network ${network.name} &`);

  const addresses3 = `export const addresses = {\n` + `  nounsDescriptor:"${nounsDescriptor.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/nounsDescriptor_${network.name}.ts`, addresses3, () => { });

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
import { ethers, network } from 'hardhat';
import { writeFile } from 'fs';
import { addresses } from '../../src/utils/addresses';

const assetStoreAddress = addresses.assetStore[network.name];
const tokenGateAddress = addresses.tokenGate[network.name];
const splatterToken = addresses.splatterToken[network.name];
export const proxy =
  network.name == 'goerli'
    ? '0x3143867c145F73AF4E03a13DdCbdB555210e2027' // dummy proxy
    : '0xa5409ec958c83c3f309868babaca7c86dcb077c1'; // openSea proxy

console.log('assetStoreAddress', assetStoreAddress);
console.log('tokenGateAddress', tokenGateAddress);
console.log('splatterToken', splatterToken);
console.log('proxyAddress', proxy);

const contract = addresses.assetStoreProvider[network.name];
const contractCoin = addresses.coinProvider[network.name];
const contractSchemes = addresses.colorSchemes[network.name];
console.log('contract', contract);
console.log('contractCoin', contractCoin);
console.log('contractSchemes', contractSchemes);

const waitForUserInput = (text: string) => {
  return new Promise((resolve, reject) => {
    process.stdin.resume();
    process.stdout.write(text);
    process.stdin.once('data', data => resolve(data.toString().trim()));
  });
};

async function main() {
  const assetId = network.name == 'mainnet' ? 1505 : 20; // bitcoin: 1505/20
  console.log('assetId', assetId);
  await waitForUserInput('Continue?');

  const factoryArt = await ethers.getContractFactory('RepeatProvider');
  const contractArt = await factoryArt.deploy(contractCoin, contractSchemes, assetId, 'bitcoinArt', 'On-chain Bitcoin');
  await contractArt.deployed();
  console.log(`      bitcoinArt="${contractArt.address}"`);

  const factoryToken = await ethers.getContractFactory('BitcoinToken');
  const token = await factoryToken.deploy(splatterToken, contractArt.address, proxy);
  await token.deployed();
  console.log(`      token="${token.address}"`);

  const addresses =
    `export const addresses = {\n` +
    `  assetStoreProvider:"${contract}",\n` +
    `  coinProvider:"${contractCoin}",\n` +
    `  colorSchemes:"${contractSchemes}",\n` +
    `  bitcoinArtProvider:"${contractArt.address}",\n` +
    `  bitcoinToken:"${token.address}"\n` +
    `}\n`;
  await writeFile(`../src/utils/addresses/bitcoin_${network.name}.ts`, addresses, () => {});
  console.log('Complete');
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

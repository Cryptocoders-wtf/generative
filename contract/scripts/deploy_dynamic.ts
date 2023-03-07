import { ethers, network } from 'hardhat';
import { writeFile } from 'fs';
import { addresses } from '../../src/utils/addresses';

const splatterTokenAddress = addresses.splatterToken[network.name];
const bitcoinTokenAddress = addresses.bitcoinToken[network.name];
console.log('bitcoinTokenAddress', bitcoinTokenAddress);

async function main() {
  let result;
  const [owner] = await ethers.getSigners();
  console.log('owner', owner.address);

  const splatterFactory = await ethers.getContractFactory('SplatterToken');
  const splatterToken = await splatterFactory.attach(splatterTokenAddress);

  result = await splatterToken.balanceOf(owner.address);
  console.log('splatter owner', result);
  result = await splatterToken.balanceOf('0x4E4cD175f812f1Ba784a69C1f8AC8dAa52AD7e2B');
  console.log('splatter user1', result);

  const factory = await ethers.getContractFactory('DynamicTokenGate');
  const contract = await factory.deploy();
  await contract.deployed();
  console.log(`      tokenGate="${contract.address}"`);

  result = await contract.balanceOf(owner.address);
  console.log('result2', result);
  result = await contract.balanceOf('0x4E4cD175f812f1Ba784a69C1f8AC8dAa52AD7e2B');
  console.log('result3', result);

  const tx = await contract.append(splatterTokenAddress);
  await tx.wait();

  if (bitcoinTokenAddress) {
    const bitcoinFactory = await ethers.getContractFactory('BitcoinToken');
    const bitcoinToken = await bitcoinFactory.attach(bitcoinTokenAddress);
    result = await bitcoinToken.balanceOf(owner.address);
    console.log('bitcoinToken owner', result);
    result = await bitcoinToken.balanceOf('0x4E4cD175f812f1Ba784a69C1f8AC8dAa52AD7e2B');
    console.log('bitcoinToken user1', result);

    const tx2 = await contract.append(bitcoinTokenAddress);
    await tx2.wait();
  } else {
    console.log('skipping bitcoinToken');
  }

  result = await contract.balanceOf(owner.address);
  console.log('result4', result);
  result = await contract.balanceOf('0x4E4cD175f812f1Ba784a69C1f8AC8dAa52AD7e2B');
  console.log('result5', result);

  const addresses = `export const addresses = {\n` + `  tokenGate:"${contract.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/dynamic_${network.name}.ts`, addresses, () => {});
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

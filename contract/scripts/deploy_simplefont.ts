import { ethers, network } from 'hardhat';
import { addresses } from '../../src/utils/addresses';

// for mainnet forkng
console.log("you need run mainnet forking node: run npx hardhat node --fork https://eth-mainnet.alchemyapi.io/v2/xxxxxx");

const lonrinaFont = addresses.londrina_solid["mainnet"];

async function main() {
  const factory = await ethers.getContractFactory('SimpleFontToken');
  const contract = await factory.deploy("SimpleFontToken", "Font", lonrinaFont);
  await contract.deployed();
  console.log(`      simple="${contract.address}"`);
  
  await contract.mint();
  await contract.mint();
  await contract.mint();
  await contract.mint();

  const res = await contract.tokenURI(1);
  console.log(res);
  const res2 = await contract.debugGenerateSVG(1);
  console.log(res2);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

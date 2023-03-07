import { ethers, network } from 'hardhat';
import { writeFile } from 'fs';
import { addresses } from '../../src/utils/addresses';

let contractSchemesAddress = addresses.colorSchemes[network.name];
console.log('contractSchemes', contractSchemesAddress);

const waitForUserInput = (text: string) => {
  return new Promise((resolve, reject) => {
    process.stdin.resume();
    process.stdout.write(text);
    process.stdin.once('data', data => resolve(data.toString().trim()));
  });
};

async function main() {
  if (network.name == 'localhost') {
    const factorySchemes = await ethers.getContractFactory('ColorSchemes');
    const contractSchemes = await factorySchemes.deploy();
    await contractSchemes.deployed();
    console.log(`      colorSchemes="${contractSchemes.address}"`);
    contractSchemesAddress = contractSchemes.address;
  }

  const factoryGenerator = await ethers.getContractFactory('MatrixGenerator');
  const contractGenerator = await factoryGenerator.deploy();
  await contractGenerator.deployed();
  console.log(`      contractGenerator="${contractGenerator.address}"`);

  const factoryArt = await ethers.getContractFactory('CirclesProvider');
  const contractArt = await factoryArt.deploy(contractGenerator.address, contractSchemesAddress);
  await contractArt.deployed();
  console.log(`      contractArt="${contractArt.address}"`);

  const factoryCircleStencil = await ethers.getContractFactory('CircleStencilProvider');
  const contractCircleStencil = await factoryCircleStencil.deploy(contractGenerator.address, contractSchemesAddress);
  await contractCircleStencil.deployed();
  console.log(`      contractCircleStencil="${contractCircleStencil.address}"`);

  const factoryStencil = await ethers.getContractFactory('StencilProvider');
  const contractStencil = await factoryStencil.deploy(contractGenerator.address, contractSchemesAddress);
  await contractStencil.deployed();
  console.log(`      contractStencil="${contractStencil.address}"`);

  const factoryGlasses = await ethers.getContractFactory('GlassesStencilProvider');
  const contractGlasses = await factoryGlasses.deploy(contractGenerator.address, contractSchemesAddress);
  await contractGlasses.deployed();
  console.log(`      contractGlasses="${contractGlasses.address}"`);

  const result = await contractArt.generateSVGPart(0);
  console.log('result', result);

  const addresses =
    `export const addresses = {\n` +
    `  matrixGenerator:"${contractGenerator.address}",\n` +
    `  contractArt:"${contractArt.address}",\n` +
    `  contractCircleStencil:"${contractCircleStencil.address}",\n` +
    `  contractStencil:"${contractStencil.address}",\n` +
    `  contractGlassesStencil:"${contractGlasses.address}",\n` +
    `}\n`;
  await writeFile(`../src/utils/addresses/circles_${network.name}.ts`, addresses, () => {});
  console.log('Complete');
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

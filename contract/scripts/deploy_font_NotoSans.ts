import { ethers, network } from 'hardhat';
import { writeFile } from 'fs';

const designer = '0x778577c329947F9CA65b15a26096F474F9A4e674';
async function main() {
  const factory = await ethers.getContractFactory('NotoSans');
  const font = await factory.deploy(designer);
  await font.deployed();
  console.log(`      font="${font.address}"`);

  /*
  const result = await font.widthOf("a");
  console.log(result);
  */

  const addresses = `export const addresses = {\n` + `  font:"${font.address}",\n` + `}\n`;
  await writeFile(`../src/utils/addresses/londrina_solid_${network.name}.ts`, addresses, () => {});
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

import { ethers, network } from "hardhat";
import { writeFile } from "fs";

const deploy = async (name: string, args: any) => {
  const factory = await ethers.getContractFactory(name);
  const contract = (args) ? await factory.deploy(args) : await factory.deploy();
  await contract.deployed();
  return contract;
  // console.log(`      test="${contract.address}"`);
};

const deployNFT = async (name: string, args: any, args2: any) => {
  const factory = await ethers.getContractFactory(name);
  const contract = await factory.deploy(args, args2);
  await contract.deployed();
  return contract;
  // console.log(`      test="${contract.address}"`);
};
async function main() {

  
  const cons = [
    "LuPartsBgBlue",
    "LuPartsBgRainbow",
    "LuPartsChair",
    "LuPartsDoor2",
    "LuPartsDoor7",
    "LuPartsHeart1",
    "LuPartsHeart2",
    "LuPartsHeart3",
    "LuPartsHeartSP",
    "LuPartsHouse",
    "LuPartsLu1",
    "LuPartsLu2",
    "LuPartsRoof01",
    "LuPartsRoof05",
    "LuPartsTextSweet",
    "LuPartsWindows1",
    "LuPartsWindows2",
    "LuPartsWindows3",
  ];
  
  const partsList = [];
  for await (let con of cons) {
    const partsContract = await deploy(con);
    // console.log(con);
    console.log(`      parts="${partsContract.address}"`);
    // await contract.register(con, partsContract.address);
    partsList.push(partsContract.address);
  }

  
  const contract = await deploy("LuArt1", partsList);
  console.log(`      test="${contract.address}"`);
  // const result = await contract.getParts(2);
  // const result2 = await contract.Roof05()
  const result3 = await contract.getSVG(0)
  const result4 = await contract.getSVG(1)
  const result5 = await contract.getSVG(2)
  
  await writeFile(`./cache/lu_test.svg`, result3, ()=>{});  
  // console.log(result);
  // console.log(result2);


  console.log(result3);
  console.log("---------");
  console.log(result4);
  console.log("---------");
  console.log(result5);
  console.log("---------");

  /////

  const providerContract = await deploy("LuArtProvider", contract.address);
  console.log(`      prodider="${providerContract.address}"`);
  const result6 = await providerContract.generateSVGDocument(0);
  await writeFile(`./cache/lu_test6.svg`, result6, ()=>{});  
  
  const factoryToken = await ethers.getContractFactory("LuToken");
  const token = await factoryToken.deploy(providerContract.address);

//  await token.mint();
  console.log("mint")
  await token.mint( { value: ethers.utils.parseEther("0.01") });
  await token.mint( { value: ethers.utils.parseEther("0.01") });
  await token.mint( { value: ethers.utils.parseEther("1") });
  // await token.mint();
  // await token.mint();
  const svg = await token.tokenURI(5);
  console.log(svg);

  //////
/*  
  const factory = await ethers.getContractFactory("LuToken");
  const contract2 = await factory.deploy("Lu", "Lu", contract.address);
  await contract2.deployed();
  console.log(`      nft="${contract2.address}"`);
  const hoge = await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  await contract2.mint();
  const svg = await contract2.tokenURI(1);
  console.log(svg);
*/

  /*
  const contract = await deployNFT("LuToken", "Lu", "Lu");
  console.log(`      test="${contract.address}"`);
  */
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

import { expect } from "chai";
import { ethers } from "hardhat";

export const proxy = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";

let assetTokenGate:any;
let contractHelper:any;
let contractSplatter:any;
let contractArt:any;

before(async() => {
  const tokenGateFactory = await ethers.getContractFactory("AssetTokenGate");
  assetTokenGate = await tokenGateFactory.deploy();
  await assetTokenGate.deployed();

  const factoryHelper = await ethers.getContractFactory("SVGHelperA");
  contractHelper = await factoryHelper.deploy();
  await contractHelper.deployed();

  const factory = await ethers.getContractFactory("SplatterProvider");
  contractSplatter = await factory.deploy(contractHelper.address);
  await contractSplatter.deployed();
  
  const factoryArt = await ethers.getContractFactory("MultiplexProvider");
  contractArt = await factoryArt.deploy(contractSplatter.address, "spltart", "Splatter Art");
  await contractArt.deployed();

  const factoryToken = await ethers.getContractFactory("SplatterToken");
  const token = await factoryToken.deploy(assetTokenGate.address, contractArt.address, proxy);
  await token.deployed();
});

describe("Test 1", function () {
  it("contractHelper", async function() {
    const result = await contractHelper.functions.generateSVGPart(contractSplatter.address, 1);
    expect(result.tag).equal("splt1");
  });
});
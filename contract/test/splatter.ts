import { expect } from "chai";
import { ethers } from "hardhat";

export const proxy = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";

let assetTokenGate:any;
let contractHelper:any;
let contractSplatter:any;
let testToken:any; // dummy token to test tokenGate
let contractArt:any;
let token:any;
let owner:any;

before(async() => {
  const factoryHelper = await ethers.getContractFactory("SVGHelperA");
  contractHelper = await factoryHelper.deploy();
  await contractHelper.deployed();

  const factory = await ethers.getContractFactory("SplatterProvider");
  contractSplatter = await factory.deploy(contractHelper.address);
  await contractSplatter.deployed();
  
  const testFactory = await ethers.getContractFactory("TestToken");
  testToken = await testFactory.deploy(contractSplatter.address, proxy);
  await testToken.deployed();

  const factoryArt = await ethers.getContractFactory("MultiplexProvider");
  contractArt = await factoryArt.deploy(contractSplatter.address, "spltart", "Splatter Art");
  await contractArt.deployed();

  const tokenGateFactory = await ethers.getContractFactory("AssetTokenGate");
  assetTokenGate = await tokenGateFactory.deploy();
  await assetTokenGate.deployed();

  const tx = await assetTokenGate.functions.setWhitelist([testToken.address]);
  await tx.wait();

  const factoryToken = await ethers.getContractFactory("SplatterToken");
  token = await factoryToken.deploy(assetTokenGate.address, contractArt.address, proxy);
  await token.deployed();

  [owner] = await ethers.getSigners();
});

const catchError = async (callback: any) => {
  try {
    await callback();
    console.log("unexpected success");
    return false;
  } catch(e:any) {
    return true;
  }
};

describe("Test 1", function () {
  it("contractHelper", async function() {
    const result = await contractHelper.functions.generateSVGPart(contractSplatter.address, 1);
    expect(result.tag).equal("splt1");
  });
  it("contractSplatter", async function() {
    const result = await contractSplatter.functions.generateSVGPart(1);
    expect(result.tag).equal("splt1");
  });
  it("mintLimit", async function() {
    const [mintLimit] = await token.functions.mintLimit();
    expect(mintLimit.toNumber()).equal(250);
    const tx = await token.setMintLimit(500);
    await tx.wait();
    const [mintLimit2] = await token.functions.mintLimit();
    expect(mintLimit2.toNumber()).equal(500);
    const tx2 = await token.setMintLimit(250);
    await tx2.wait();
  });
  it("mintPrice", async function() {
    const [mintPrice] = await token.functions.mintPrice();
    const halfPrice = mintPrice.div(ethers.BigNumber.from(2));
    const tx = await token.setMintPrice(halfPrice);
    await tx.wait();
    const [mintPrice2] = await token.functions.mintPrice();
    expect(mintPrice2).equal(halfPrice);
    const tx2 = await token.setMintPrice(mintPrice);
    await tx2.wait();
  });
  it("mintPriceFor", async function() {
    const [mintPrice] = await token.functions.mintPrice();
    const [myMintPrice] = await token.functions.mintPriceFor(owner.address);
    expect(mintPrice).equal(myMintPrice);
  });

  it("mint", async function() {
    const [count] = await token.functions.totalSupply();
    expect(count.toNumber()).equal(0);
    const [mintPrice] = await token.functions.mintPrice();
    const tx = await token.functions.mint({value:mintPrice});
    await tx.wait();
    const [count1] = await token.functions.balanceOf(owner.address);
    expect(count1.toNumber()).equal(1);
    const [count2] = await token.functions.totalSupply();
    expect(count2.toNumber()).equal(1);
  });
  it("sold out error", async function() {
    const [count] = await token.functions.totalSupply();
    const tx = await token.setMintLimit(count);
    await tx.wait();
    const [mintPrice] = await token.functions.mintPrice();
    const err = await catchError(async () => {
      const tx2 = await token.functions.mint({value:mintPrice});
      await tx2.wait();
    });
    expect(err).equal(true);

    const tx3 = await token.setMintLimit(250);
    await tx3.wait();
  });
  it("mint with wrong price", async function() {
    const [mintPrice] = await token.functions.mintPrice();
    const halfPrice = mintPrice.div(ethers.BigNumber.from(2));
    const err = await catchError(async () => {
      const tx = await token.functions.mint({value:halfPrice});
      await tx.wait();
    });
    expect(err).equal(true);
  });
  it("mint with whitelist token", async function() {
    const tx0 = await testToken.mint();
    await tx0.wait();

    const [mintPrice] = await token.functions.mintPrice();
    const halfPrice = mintPrice.div(ethers.BigNumber.from(2));
    const [myMintPrice] = await token.functions.mintPriceFor(owner.address);
    expect(myMintPrice).equal(halfPrice);

    const tx = await token.functions.mint({value:halfPrice});
    await tx.wait();
  });
});
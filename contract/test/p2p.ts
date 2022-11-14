import { expect } from "chai";
import { ethers, SignerWithAddress, Contract } from "hardhat";

let owner:SignerWithAddress, user1:SignerWithAddress, user2:SignerWithAddress, user3:SignerWithAddress;
let token:Contract, token1:Contract, token2:Contract, token3:Contract;

before(async() => {
  [owner, user1, user2, user3] = await ethers.getSigners();

  const factory = await ethers.getContractFactory("SampleP2PToken");
  token = await factory.deploy();
  await token.deployed();

  token1 = token.connect(user1);
  token2 = token.connect(user2);
  token3 = token.connect(user3);

});

const catchError = async (callback: any) => {
  try {
    await callback();
    console.log("unexpected success");
    return false;
  } catch(e:any) {
    console.log(e.reason);
    return true;
  }
};

describe("P2P", function () {
  let result, tx, err;
  const zeroAddress = '0x0000000000000000000000000000000000000000';
  const price = ethers.BigNumber.from("1000000000000000");
  const tokenId0 = 0;
  console.log(ethers.utils.formatEther(price));

  it("Initial TotalSupply", async function() {
    result = await token.totalSupply();
    expect(result.toNumber()).equal(0);
    result = await token.balanceOf(user1.address);
    expect(result.toNumber()).equal(0);
  });
  it("Mint by user1", async function() {
    tx = await token1.mint();
    await tx.wait();
    result = await token.totalSupply();
    expect(result.toNumber()).equal(1);
    result = await token.balanceOf(user1.address);
    expect(result.toNumber()).equal(1);
    result = await token.ownerOf(tokenId0);
    expect(result).equal(user1.address);
    result = await token.getPriceOf(tokenId0);
    expect(result.toNumber()).equal(0);
  });
  it("Attempt to buy by user2", async function() {
    err = await catchError(async () => {
      tx = await token2.purchase(0, user2.address, zeroAddress);
      await tx.wait();
    });
    expect(err).equal(true);
  });
  it("SetPrice", async function() {
    err = await catchError(async () => {
      tx = await token2.setPriceOf(tokenId0, price);
      await tx.wait();
    });
    expect(err).equal(true);
    tx = await token1.setPriceOf(tokenId0, price);
    await tx.wait();
    result = await token.getPriceOf(tokenId0);
    expect(result.toNumber()).equal(price);
  });
  it("Purchase by user2", async function() {
    err = await catchError(async () => {
      tx = await token2.purchase(tokenId0, user2.address, zeroAddress);
      await tx.wait();
    });
    expect(err).equal(true);

    tx = await token2.purchase(tokenId0, user2.address, zeroAddress, {value:price});
    await tx.wait();
    result = await token.ownerOf(tokenId0);
    expect(result).equal(user2.address);
  });
});
import { expect } from "chai";
import { ethers } from "hardhat";

let owner:any, user1:any, user2:any, user3:any;
let token:any, token1:any, token2:any, token3:any;

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
    return true;
  }
};

describe("P2P", function () {
  let result;
  it("Initial TotalSupply", async function() {
    result = await token.totalSupply();
    expect(result.toNumber()).equal(0);
    result = await token.balanceOf(user1.address);
    expect(result.toNumber()).equal(0);
  });
  it("Mint by user1", async function() {
    const tx = await token1.mint();
    await tx.wait();
    result = await token.totalSupply();
    expect(result.toNumber()).equal(1);
    result = await token.balanceOf(user1.address);
    expect(result.toNumber()).equal(1);
    result = await token.ownerOf(0);
    expect(result).equal(user1.address);
    result = await token.getPriceOf(0);
    expect(result.toNumber()).equal(0);
  });
});
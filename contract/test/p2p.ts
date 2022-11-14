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
  it("Initial TotalSupply", async function() {
    const result = await token.totalSupply();
    expect(result.toNumber()).equal(0);
    const result2 = await token.balanceOf(user1.address);
    expect(result2.toNumber()).equal(0);
  });
  it("Mint by user1", async function() {
    const tx = await token1.mint();
    await tx.wait();
    const result = await token.totalSupply();
    expect(result.toNumber()).equal(1);
    const result2 = await token.balanceOf(user1.address);
    expect(result2.toNumber()).equal(1);
  });
});
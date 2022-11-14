import { expect } from "chai";
import { ethers } from "hardhat";

let owner:any;

before(async() => {
  /*
  const factoryHelper = await ethers.getContractFactory("SVGHelperA");
  contractHelper = await factoryHelper.deploy();
  await contractHelper.deployed();
  */

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

describe("P2P", function () {
  it("test1", async function() {
    expect("test").equal("test");
  });
});
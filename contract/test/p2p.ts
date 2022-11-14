import { expect } from "chai";
import { ethers, SignerWithAddress, Contract } from "hardhat";

let owner:SignerWithAddress, artist:SignerWithAddress, user1:SignerWithAddress, user2:SignerWithAddress, user3:SignerWithAddress;
let token:Contract, token1:Contract, token2:Contract, token3:Contract;
let balanceO, balanceA, balance1, balance2, balance3;

before(async () => {
  [owner, artist, user1, user2, user3] = await ethers.getSigners();

  const factory = await ethers.getContractFactory("SampleP2PToken");
  token = await factory.deploy(artist.address);
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
    const array = e.reason.split("'");
    return array.length == 3 ? array[1] : true;
  }
};

describe("P2P", function () {
  let result, tx, err, balance;
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
    expect(err).equal('Token is not on sale');
  });
  it("SetPrice", async function() {
    err = await catchError(async () => {
      tx = await token2.setPriceOf(tokenId0, price);
      await tx.wait();
    });
    expect(err).equal('Only the onwer can set the price');
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
    expect(err).equal('Not enough fund');

    balance1 = await token.etherBalanceOf(user1.address);
    balanceA = await token.etherBalanceOf(artist.address);

    tx = await token2.purchase(tokenId0, user2.address, zeroAddress, {value:price});
    await tx.wait();
    result = await token.ownerOf(tokenId0);
    expect(result).equal(user2.address);

    balance = await token.etherBalanceOf(user1.address);
    expect(balance.sub(balance1)).equal(price.div(20).mul(19)); // 95%
    balance = await token.etherBalanceOf(artist.address);
    expect(balance.sub(balanceA)).equal(price.div(20).mul(1)); // 5%
  });
  it("Attempt to buy by user3", async function() {
    err = await catchError(async () => {
      tx = await token3.purchase(0, user2.address, zeroAddress, {value: price});
      await tx.wait();
    });
    expect(err).equal('Token is not on sale');
  });
});
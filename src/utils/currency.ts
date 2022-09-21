import { BigNumber } from "ethers";

export const aBillion = 1000000000;

export const weiToGwei = (amount: BigNumber) => {
  return amount.div(BigNumber.from(aBillion));
};

export const weiToEther = (amount: BigNumber) => {
  const amountInGwei = weiToGwei(amount);
  return amountInGwei.toNumber() / aBillion;
};

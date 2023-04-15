import { ethers } from "ethers";
import * as utils from "../lib/utils";


export const ContentsContract = {
  network: "mumbay",
  wabi: require("../abi/SVGTokenV1.json"), // wrapped abi
}

const providerViewOnly = new ethers.providers.AlchemyProvider(
  ContentsContract.network
);

export const tokenSvg = async (address:string, tokenid:string) =>{
  try{
    const contractViewOnly = new ethers.Contract(
      address,
      ContentsContract.wabi.abi,
      providerViewOnly
    );
    
    const uri = (await contractViewOnly.functions.tokenURI(tokenid))[0];
    const tokenURI = JSON.parse(
      Buffer.from(
        uri.substr("data:application/json;base64,".length),
        "base64"
      ).toString()
    );
    console.log(tokenURI);
    return tokenURI;
  } catch (error) {
    throw utils.process_error(error);
  }

}
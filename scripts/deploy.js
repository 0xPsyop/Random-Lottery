
const { resolveProperties } = require("ethers/lib/utils");
const hre = require("hardhat");
require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");
const { FEE, VRF_COORDINATOR, LINK_TOKEN, KEY_HASH } = require("../constants");


async function main() {
 
  
  const lotteryContract = await hre.ethers.getContractFactory("Lottery");
  const lottery = await lotteryContract.deploy(  VRF_COORDINATOR,
    LINK_TOKEN,
    KEY_HASH,
    FEE);

  await lottery.deployed();
  
  console.log("Verifying Contract...")
  
  await pending(60000);
  
  await hre.run("verify:verify", {
    address:lottery.address,
    constructorArguments: [VRF_COORDINATOR, LINK_TOKEN, KEY_HASH, FEE],
  });

  console.log(" Random game deployed to:", lottery.address);
}

function pending(ms){
  return new Promise(resolve => setTimeout(resolve, ms)) ;
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

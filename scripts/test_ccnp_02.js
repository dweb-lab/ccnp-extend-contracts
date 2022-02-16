var utils = require('ethers').utils;
const hre = require("hardhat")
const fs = require('fs');
const CONTRACT_ADDRESS_Simple = fs.readFileSync(".spt_addr").toString().trim() || "0x111"
const CONTRACT_ADDRESS_NFT = fs.readFileSync(".nft_addr").toString().trim() || "0x111"


async function main() {
  const NFT = await hre.ethers.getContractFactory("NFT")
  const contract = NFT.attach(CONTRACT_ADDRESS_NFT)
  const Simple = await hre.ethers.getContractFactory("Simple")
  const contract_simple = Simple.attach(CONTRACT_ADDRESS_Simple)

  const nft_addr_balance = await contract_simple.balanceOf(CONTRACT_ADDRESS_NFT)
  console.log("nft_addr_balance: ", nft_addr_balance)

  // add more funds
  var wei_amount = utils.parseEther('40.0'); // uint256 amount = 10 ether?
  const ret_transfer = await contract_simple.transfer(CONTRACT_ADDRESS_NFT, wei_amount)
  const nft_addr_balance2 = await contract_simple.balanceOf(CONTRACT_ADDRESS_NFT)
  console.log("nft_addr_balance2: ", nft_addr_balance2)

  let owners = await ethers.getSigners();
  let owner0 = owners[0];
  // provider = ethers.getDefaultProvider();
  // https://ethereum.stackexchange.com/questions/103226/hardhat-ether-js-fetching-balance-of-signers-locally-shows-no-ether
  provider = ethers.provider;
  balance = await provider.getBalance(owner0.address);
  console.log("nft_addr_balance2_matic: ", balance.toString());

}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

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

  var today = new Date();
  var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
  var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
  var dateTime = date+' '+time;
  console.log("dateTime: ", dateTime)

  // for (let i = 0; i < 12; i++) {
  for (let i = 0; i < 5; i++) {
    await contract.createToken("https://bafy.xxx")
  }

  today = new Date();
  date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
  time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
  dateTime = date+' '+time;
  console.log("dateTime: ", dateTime)

  const nft_addr_balance3 = await contract_simple.balanceOf(CONTRACT_ADDRESS_NFT)
  console.log("nft_addr_balance3: ", nft_addr_balance3)

  const owner = await contract.ownerOf(2)
  console.log("Owner:", owner)
  const uri = await contract.tokenURI(2)
  console.log("URI: ", uri)

  console.log("name: ", await contract.name())
  console.log("symbol: ", await contract.symbol())
  console.log("totalSupply: ", await contract.totalSupply())
  if (await contract.exists(1)) {
    const ret2 = await contract.burn(1)
  } else {
    console.log("already burned")
  }

  console.log("totalSupply: ", await contract.totalSupply())
  console.log("tokensOfOwner: ", await contract.tokensOfOwner(owner, 1, 2))
  console.log("tokensOfOwner: ", await contract.tokensOfOwner(owner, 2, 2))
  console.log("tokenOfOwnerByIndex: ", await contract.tokenOfOwnerByIndex(owner, 0))

  const donation_amount = utils.parseEther('0.1')
  const ret_mintAsDonorFromAuthor = await contract.mintAsDonorFromAuthor("https://bafy.yyy", owner, {
      value: donation_amount,
  }); // will cost 0.2 spt

  console.log("totalSupply2: ", await contract.totalSupply())
  // const ret_withdraw = await contract.withdrawToken(CONTRACT_ADDRESS_Simple, utils.parseEther('4.0'));

  const nft_addr_balance4 = await contract_simple.balanceOf(CONTRACT_ADDRESS_NFT)
  console.log("nft_addr_balance4: ", nft_addr_balance4)

  const owner0_addr_balance4 = await contract_simple.balanceOf(owner0.address)
  console.log("owner0_addr_balance4: ", owner0_addr_balance4)

}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

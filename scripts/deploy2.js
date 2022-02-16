const hre = require("hardhat")
const fs = require("fs")
const spt_addr = fs.readFileSync(".spt_addr").toString().trim() || "0x111"

async function main() {
  const NFTMarket = await hre.ethers.getContractFactory("NFTMarket")
  const nftMarket = await NFTMarket.deploy()
  await nftMarket.deployed()
  console.log("nftMarket deployed to:", nftMarket.address)

  const NFT = await hre.ethers.getContractFactory("NFT")
  const nft = await NFT.deploy(nftMarket.address, spt_addr)
  await nft.deployed()
  console.log("nft deployed to:", nft.address)

  const config = `
export const simpletokenaddress = "${spt_addr}"
export const nftmarketaddress = "${nftMarket.address}"
export const nftaddress = "${nft.address}"
`

  const data = JSON.stringify(config)
  fs.writeFileSync("config.js", JSON.parse(data))

  const nft_addr = `${nft.address}`
  const data_nft_addr = JSON.stringify(nft.address)
  fs.writeFileSync(".nft_addr", JSON.parse(data_nft_addr))
  const market_addr = `${nftMarket.address}`
  const data_market_addr = JSON.stringify(nftMarket.address)
  fs.writeFileSync(".market_addr", JSON.parse(data_market_addr))
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

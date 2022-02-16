const hre = require("hardhat");
const fs = require('fs');
var utils = require('ethers').utils;

async function main() {
  // prepare
  const [owner] = await ethers.getSigners();
  console.log('owner', owner.address);
  const SimpleToken = await hre.ethers.getContractFactory('Simple');
  console.log('Deploying TestScore...');
  const supply_amount = utils.parseEther('2000000000')
  const spt = await SimpleToken.deploy('TestScore', 'TESTS', supply_amount); // 10000
  await spt.deployed();
  console.log("spt deployed to:", spt.address);

  let spt_addr = `${spt.address}`
  let data_spt_addr = JSON.stringify(spt_addr)
  fs.writeFileSync(".spt_addr", JSON.parse(data_spt_addr))

  const ownerBalance = await spt.balanceOf(owner.address);
  const total = await spt.totalSupply();
  // info
  console.log('ownerBalance', ownerBalance);
  console.log('total', total);

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

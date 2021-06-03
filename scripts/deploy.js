const hre = require("hardhat");
const fs = require('fs')

async function main() {
  const path = '/../src/Metadata.js'

  const TNFT = await hre.ethers.getContractFactory("TNFT");
  const TSC = await hre.ethers.getContractFactory("TSC");
  const CMG = await hre.ethers.getContractFactory("CMG");

  // Deploy test NFT contract
  const _TNFT = await TNFT.deploy();
  await _TNFT.deployed();
  var TNFT_address = _TNFT.address;
  console.log('Test NFT deployed to:', TNFT_address);

  // Mint a new NFT to Hardhat's default 2nd address
  _TNFT.awardItem('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');

  // Deploy Test Stable Coin
  // TSC will send all supply to first hardhat address
  const _TSC = await TSC.deploy();
  await _TSC.deployed();
  var TSC_address = _TSC.address;
  console.log('Test StableCoin deployed to:', TSC_address);
  balance = await _TSC.balanceOf("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266");
  console.log("minted", ethers.utils.formatUnits(balance, 18), "TSC");

  // Deploy Cover My Gas Contract
  const _CMG = await CMG.deploy(TNFT_address, TSC_address);
  await _CMG.deployed();

  console.log('Cover My Gas deployed to:', _CMG.address)

  fs.writeFile(
    __dirname + path,
    'const TNFT_ADDRESS = ' + "'" + _TNFT.address + "';\n" + 'const TSC_ADDRESS = ' + "'" + _TSC.address + "';\n" + 'const CMG_ADDRESS = ' + "'" + _CMG.address + "';",
    (err) => {
      if (err) {
        console.log(err)
      } else {
      }
    },
  )
  fs.appendFile(
    __dirname + path,
    '\nconst TNFT_ABI = ' + JSON.stringify(_TNFT.abi) + ';\n' + 'const TSC_ABI = ' + JSON.stringify(_TSC.abi) + ';\n' + 'const CMG_ABI = ' + JSON.stringify(_CMG.abi) + ';\n',
    (err) => {
      if (err) {
        console.log(err)
      } else {
        fs.appendFile(
          __dirname + path,
          '\nmodule.exports = { ADDRESS, ABI };',
          (err) => {
            if (err) {
              console.log(err)
            }
          },
        )
      }
    },
  )
}


main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

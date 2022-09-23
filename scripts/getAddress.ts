import { ethers } from 'hardhat';

async function main() {
  const address = '0xe8366E50ed089Eea4df663116e257B5D79fbD953';
  const nonce = '0x5d';
  const anticipatedAddress = ethers.utils.getContractAddress({
    from: address,
    nonce,
  });
  console.log(`Anticipated address ${anticipatedAddress}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

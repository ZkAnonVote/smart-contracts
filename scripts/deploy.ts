import { ethers } from "hardhat";

async function main() {
  const APP_ID = `0x11b1de449c6c4adb0b5775b3868b28b3`;
  const GROUP_ID = `0x0cc0c43792cec360c9aee6af04acc22b`;

  const ZkBallotBox = await ethers.getContractFactory("ZkBallotBox");
  const contract = await ZkBallotBox.deploy(GROUP_ID, APP_ID);

  await contract.deployed();

  console.log(`
      ZkBallotBox(appId=${APP_ID}, groupId=${GROUP_ID})
      deployed to ${contract.address}
  `);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

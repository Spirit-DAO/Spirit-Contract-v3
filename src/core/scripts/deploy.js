const hre = require('hardhat');
const fs = require('fs');
const path = require('path');

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  // precompute
  const poolDeployerAddress = hre.ethers.getCreateAddress({
    from: deployer.address,
    nonce: (await ethers.provider.getTransactionCount(deployer.address)) + 1,
  });

  const AlgebraFactory = await hre.ethers.getContractFactory('AlgebraFactory');
  let factory = await AlgebraFactory.deploy(poolDeployerAddress);

  factory = await factory.waitForDeployment();

  const PoolDeployerFactory = await hre.ethers.getContractFactory('AlgebraPoolDeployer');
  let poolDeployer = await PoolDeployerFactory.deploy(factory.target);

  poolDeployer = await poolDeployer.waitForDeployment();

  console.log('AlgebraPoolDeployer to:', poolDeployer.target);
  console.log('AlgebraFactory deployed to:', factory.target);

  const vaultFactory = await hre.ethers.getContractFactory('AlgebraCommunityVault');
  let vault = await vaultFactory.deploy(factory, deployer.address);

  vault = await vault.waitForDeployment();

  console.log('AlgebraCommunityVault deployed to:', vault.target);

  const vaultFactoryStubFactory = await hre.ethers.getContractFactory('AlgebraVaultFactoryStub');
  let vaultFactoryStub = await vaultFactoryStubFactory.deploy(vault);

  vaultFactoryStub = await vaultFactoryStub.waitForDeployment();

  console.log('AlgebraVaultFactoryStub deployed to:', vaultFactoryStub.target);

  await factory.setVaultFactory(vaultFactoryStub);

  const deployDataPath = path.resolve(__dirname, '../../../deploys.json');
  let deploysData = JSON.parse(fs.readFileSync(deployDataPath, 'utf8'));
  deploysData.poolDeployer = poolDeployer.target;
  deploysData.factory = factory.target;
  deploysData.vault = vault.target;
  deploysData.vaultFactory = vaultFactoryStub.target;
  fs.writeFileSync(deployDataPath, JSON.stringify(deploysData), 'utf-8');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

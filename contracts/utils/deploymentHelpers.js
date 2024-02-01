// Borrowing contracts
const SortedTroves = artifacts.require("./SortedTroves.sol");
const TroveManager = artifacts.require("./TroveManager.sol");
const PriceFeedTestnet = artifacts.require("./PriceFeedTestnet.sol");
const ActivePool = artifacts.require("./ActivePool.sol");
const DefaultPool = artifacts.require("./DefaultPool.sol");
const GasPool = artifacts.require("./GasPool.sol");
const CollSurplusPool = artifacts.require("./CollSurplusPool.sol");
const FunctionCaller = artifacts.require("./TestContracts/FunctionCaller.sol");
const BorrowerOperations = artifacts.require("./BorrowerOperations.sol");
const HintHelpers = artifacts.require("./HintHelpers.sol");
const BoldToken = artifacts.require("./BoldToken.sol");
const BoldTokenTester = artifacts.require("./TestContracts/BoldTokenTester.sol");
const StabilityPool = artifacts.require("./StabilityPool.sol");
const PriceFeedMock = artifacts.require("./PriceFeedMock.sol");
// const ERC20 = artifacts.require(
// //  "@openzeppelin/contracts/token/ERC20/ERC20.sol"
//   "../node_modules/@openzeppelin/contracts/build/contracts/ERC20.json"
// );

const { web3, ethers } = require("hardhat");
const { accountsList } = require("../hardhatAccountsList2k.js");
const { fundAccounts } = require("./fundAccounts.js");

const maxBytes32 = "0x" + "f".repeat(64);

class DeploymentHelper {
  static async deployLiquityCore() {
    return await this.deployLiquityCoreHardhat();
  }

  static async deployLiquityCoreHardhat() {
    // Borrowing contracts
    const activePool = await ActivePool.new();
    const borrowerOperations = await BorrowerOperations.new();
    const collSurplusPool = await CollSurplusPool.new();
    const defaultPool = await DefaultPool.new();
    const gasPool = await GasPool.new();
    const priceFeedTestnet = await PriceFeedTestnet.new();
    const priceFeed = await PriceFeedMock.new();
    const sortedTroves = await SortedTroves.new();
    const stabilityPool = await StabilityPool.new();
    const troveManager = await TroveManager.new();
    const boldToken = await BoldToken.new(
      troveManager.address,
      stabilityPool.address,
      borrowerOperations.address
    );

    const functionCaller = await FunctionCaller.new();
    const hintHelpers = await HintHelpers.new();
      
    // // Needed?
    // const price = await priceFeed.getPrice();
    // const uint128Max = web3.utils.toBN(
    //   "340282366920938463463374607431768211455"
    // );
    // const uint192Max = web3.utils.toBN(
    //   "6277101735386680763835789423207666416102355444464034512895"
    // );

    // TODO: setAsDeployed all above?

    BoldToken.setAsDeployed(boldToken);
    DefaultPool.setAsDeployed(defaultPool);
    PriceFeedTestnet.setAsDeployed(priceFeedTestnet);
    SortedTroves.setAsDeployed(sortedTroves);
    TroveManager.setAsDeployed(troveManager);
    ActivePool.setAsDeployed(activePool);
    StabilityPool.setAsDeployed(stabilityPool);
    GasPool.setAsDeployed(gasPool);
    CollSurplusPool.setAsDeployed(collSurplusPool);
    FunctionCaller.setAsDeployed(functionCaller);
    BorrowerOperations.setAsDeployed(borrowerOperations);
    HintHelpers.setAsDeployed(hintHelpers);

    const coreContracts = {
      //stETH,
      priceFeedTestnet,
      boldToken,
      sortedTroves,
      troveManager,
      activePool,
      stabilityPool,
      gasPool,
      defaultPool,
      collSurplusPool,
      functionCaller,
      borrowerOperations,
      hintHelpers
    };
    return coreContracts;
  }

  static async deployBoldToken(contracts) {
    contracts.boldToken = await BoldToken.new(
      contracts.troveManager.address,
      contracts.stabilityPool.address,
      contracts.borrowerOperations.address
    );
    return contracts;
  }

  static async deployBoldTokenTester(contracts) {
    contracts.boldToken = await BoldTokenTester.new(
      contracts.troveManager.address,
      contracts.stabilityPool.address,
      contracts.borrowerOperations.address
    );
    return contracts;
  }

  // Connect contracts to their dependencies
  static async connectCoreContracts(contracts) {
      // set contracts in the Trove Manager
      await contracts.troveManager.setAddresses(
        contracts.borrowerOperations.address,
        contracts.activePool.address,
        contracts.defaultPool.address,
        contracts.stabilityPool.address,
        contracts.gasPool.address,
        contracts.collSurplusPool.address,
        contracts.priceFeedTestnet.address,
        contracts.boldToken.address,
        contracts.sortedTroves.address
      );

    await contracts.stabilityPool.setAddresses(
      contracts.borrowerOperations.address,
      contracts.troveManager.address,
      contracts.activePool.address,
      contracts.boldToken.address,
      contracts.sortedTroves.address,
      contracts.priceFeedTestnet.address
    );
    // set TroveManager addr in SortedTroves
    await contracts.sortedTroves.setParams(
      maxBytes32,
      contracts.troveManager.address,
      contracts.borrowerOperations.address
    );

    // set contract addresses in the FunctionCaller
    await contracts.functionCaller.setTroveManagerAddress(
      contracts.troveManager.address
    );
    await contracts.functionCaller.setSortedTrovesAddress(
      contracts.sortedTroves.address
    );

    // set contracts in BorrowerOperations
    await contracts.borrowerOperations.setAddresses(
      contracts.troveManager.address,
      contracts.activePool.address,
      contracts.defaultPool.address,
      contracts.stabilityPool.address,
      contracts.gasPool.address,
      contracts.collSurplusPool.address,
      contracts.priceFeedTestnet.address,
      contracts.sortedTroves.address,
      contracts.boldToken.address
      //contracts.stETH.address
    );

    await contracts.activePool.setAddresses(
      contracts.borrowerOperations.address,
      contracts.troveManager.address,
      contracts.stabilityPool.address,
      contracts.defaultPool.address,
      //contracts.stETH.address,
    );

    await contracts.defaultPool.setAddresses(
      contracts.troveManager.address,
      contracts.activePool.address,
      //contracts.stETH.address
    );

    await contracts.collSurplusPool.setAddresses(
      contracts.borrowerOperations.address,
      contracts.troveManager.address,
      contracts.activePool.address,
    );

    // set contracts in HintHelpers
    await contracts.hintHelpers.setAddresses(
      contracts.sortedTroves.address,
      contracts.troveManager.address
    );
  }
}
module.exports = DeploymentHelper;

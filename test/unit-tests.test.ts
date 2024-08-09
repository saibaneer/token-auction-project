import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { AuctionFactory } from "../typechain-types";

let auctionFactory: AuctionFactory;



describe("Unit Tests", function () {
  async function deployContractsFixture() {
    const [owner, user1, user2] = await ethers.getSigners();

    const AuctionModel0 = await ethers.getContractFactory("AuctionEntrypoint");
    const auctionModel0 = await AuctionModel0.deploy();

    const AuctionFactory = await ethers.getContractFactory("AuctionFactory");
    auctionFactory = await AuctionFactory.deploy(
      await auctionModel0.getAddress()
    );

    const AuctionAsset = await ethers.getContractFactory("AuctionAsset");
    const token = await AuctionAsset.deploy(5000);

    const PaymentToken = await ethers.getContractFactory("PaymentERC20");
    const stablecoin = await PaymentToken.deploy(500000);

    return {
      owner,
      user1,
      user2,
      auctionModel0,
      auctionFactory,
      token,
      stablecoin,
    };
  }

  describe("Create New Auction", function () {
    this.beforeEach(async function () {
      const fixtures = await loadFixture(deployContractsFixture);
      Object.assign(this, fixtures);
      const { owner, user1, auctionModel0, auctionFactory, token, stablecoin } =
        this;
      const t1 = Date.now() + 60;
      const t2 = Date.now() + 60 * 60 * 24;
      const auctionParameters = createAuctionParameters(
        await token.getAddress(),
        2000,
        ethers.parseEther("0.5"),
        await stablecoin.getAddress(),
        user1.address,
        t1,
        t2
      );
    //   console.log("Auction Parameters are: ", auctionParameters);
      this.auctionParameters = auctionParameters;
      
    });
    it("should initialize a new auction", async function(){
        const { owner, user1, auctionModel0, token, stablecoin, auctionParameters } =
        this;

        console.log(auctionParameters)
        
        //create a new auction
        const newAuctionAddress = await auctionFactory.createAuction(auctionParameters);
        // console.log("Auction address is: ", newAuctionAddress)

    })
  });
//   describe("Test slope");
//   describe("Test Pricing Logic");
//   describe("Test Token Purchase");
//   describe("Test Claim function");
//   describe("Test Withdrawals");
});


export function createAuctionParameters(
    tokenAddress: string,
    numberOfTokens: number,
    startingPrice: bigint,
    acceptedStable: string,
    creator: string,
    auctionStartTime: number,
    auctionEndTime: number
  ) {
    if (typeof tokenAddress !== "string") throw new Error("Invalid Address!");
    if (typeof startingPrice !== "bigint")
      throw new Error("Invalid Starting Price");
    if (typeof numberOfTokens !== "number")
      throw new Error("Invalid Number of tokens!");
    if (typeof acceptedStable !== "string")
      throw new Error("Invalid Token Address");
    if (typeof creator !== "string") throw new Error("Invalid creator string");
    if (typeof auctionStartTime !== "number")
      throw new Error("Invalid start time!");
    if (typeof auctionEndTime !== "number") throw new Error("Invalid End time");
  
    return {
      tokenAddress,
      numberOfTokens: ethers.parseEther(numberOfTokens.toString()),
      startingPrice,
      acceptedStable,
      creator,
      auctionStartTime,
      auctionEndTime,
    };
  }
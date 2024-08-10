import { expect } from "chai";
import { ethers } from "hardhat";
import {
  AuctionAsset,
  AuctionEntrypoint,
  AuctionFactory,
  PaymentERC20,
} from "../typechain-types";
import { AuctionCreationParams, PricingLogic } from "./constants";
import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

let auctionFactory: AuctionFactory;
let token: AuctionAsset;
let stablecoin: PaymentERC20;
let auctionContract: AuctionEntrypoint;
let auctionAddress1: string;

describe.only("Auction Factory", function () {
  async function deployContractsFixture() {
    const [owner, user1, user2] = await ethers.getSigners();

    const AuctionModel0 = await ethers.getContractFactory("AuctionEntrypoint");
    auctionContract = await AuctionModel0.deploy();

    const AuctionFactory = await ethers.getContractFactory("AuctionFactory");
    auctionFactory = await AuctionFactory.deploy(
      await auctionContract.getAddress()
    );

    const AuctionAsset = await ethers.getContractFactory("AuctionAsset");
    token = await AuctionAsset.deploy(ethers.parseEther("5000"));
    await token.mint(user1.address, ethers.parseEther("500"));

    const PaymentToken = await ethers.getContractFactory("PaymentERC20");
    stablecoin = await PaymentToken.deploy(ethers.parseEther("500000"));
    await stablecoin.mint(user2.address, ethers.parseEther("5000"));

    return { owner, user1, user2 };
  }

  async function createAuctionParams(user1: any) {
    return {
      tokenAddress: await token.getAddress(),
      numberOfTokens: ethers.parseEther("500"),
      startingPrice: ethers.parseEther("0.5"),
      acceptedStable: await stablecoin.getAddress(),
      creator: user1.address,
      auctionStartTime: await time.latest(),
      auctionEndTime: await time.latest() + 3600,
      logic: PricingLogic.LinearFunction,
    };
  }

  async function createAndFundAuction(user1: any) {
    const auctionParams = await createAuctionParams(user1);
    auctionAddress1 = await auctionFactory.connect(user1).createAuction.staticCall(auctionParams);
    await auctionFactory.connect(user1).createAuction(auctionParams);

    const newAuction = await ethers.getContractAt("AuctionEntrypoint", auctionAddress1);

    await token.connect(user1).approve(auctionAddress1, ethers.parseEther("500"));
    expect(await token.balanceOf(auctionAddress1)).to.equal(0);
    await newAuction.connect(user1).fundAuction();
    expect(await token.balanceOf(auctionAddress1)).to.equal(ethers.parseEther("500"));

    return { newAuction, auctionParams };
  }

  beforeEach(async function () {
    const { owner, user1, user2 } = await loadFixture(deployContractsFixture);
  });

  it("should allow the user to update the master model", async function () {
    const { owner } = await loadFixture(deployContractsFixture);

    const AuctionModel0 = await ethers.getContractFactory("AuctionEntrypoint");
    const newAuctionModel0 = await AuctionModel0.deploy();

    await auctionFactory.connect(owner).updateMasterModel(await newAuctionModel0.getAddress());
    expect(await auctionFactory.masterAuctionEntryPoint()).to.equal(await newAuctionModel0.getAddress());
  });

  it("should allow the user to create a new auction", async function () {
    const { owner, user1 } = await loadFixture(deployContractsFixture);
    const auctionParams = await createAuctionParams(user1);

    const auctionAddress = await auctionFactory.connect(owner).createAuction.staticCall(auctionParams);
    await auctionFactory.connect(user1).createAuction(auctionParams);

    const newAuction = await ethers.getContractAt("AuctionEntrypoint", auctionAddress);
    

    expect(auctionAddress).to.be.a("string");
    expect(await newAuction.auctionStartTime()).to.equal(auctionParams.auctionStartTime);
    expect(await newAuction.auctionEndTime()).to.equal(auctionParams.auctionEndTime);
    expect(await newAuction.creator()).to.equal(auctionParams.creator);
    expect(await newAuction.startingBidPrice()).to.equal(auctionParams.startingPrice);
  });

  it("should fund an auction", async function () {
    const { user1 } = await loadFixture(deployContractsFixture);
    const { newAuction } = await createAndFundAuction(user1);

    expect(await token.balanceOf(newAuction)).to.equal(ethers.parseEther("500"));
  });

  it("should set the slope on a funded auction", async function () {
    const { user1 } = await loadFixture(deployContractsFixture);
    const { newAuction } = await createAndFundAuction(user1);

    expect(await newAuction.chargePerUnitToken()).to.equal(0);
    await newAuction.connect(user1).setSlope(ethers.parseEther("0.25"));
    expect(await newAuction.chargePerUnitToken()).to.equal(ethers.parseEther("0.25"));
  });

  it("should allow a user to enter auctions", async function () {
    const { user1, user2 } = await loadFixture(deployContractsFixture);
    const { newAuction } = await createAndFundAuction(user1);

    await newAuction.connect(user1).setSlope(ethers.parseEther("0.25"));

    const amountDue = await newAuction.connect(user2).amountDueForPurchase("20");

    await stablecoin.connect(user2).approve(newAuction, ethers.parseEther("100"));
    await newAuction.connect(user2).buyTokensWithStableCoin("20");

    expect(await newAuction.balances(user2.address)).to.equal(ethers.parseEther("20"));
    expect(await stablecoin.balanceOf(newAuction)).to.equal(amountDue.toString());
  });

  it("should allow user claim tokens after auction ends", async function () {
    const { user1, user2 } = await loadFixture(deployContractsFixture);
    const { newAuction, auctionParams } = await createAndFundAuction(user1);

    await newAuction.connect(user1).setSlope(ethers.parseEther("0.25"));
    const amountDue = await newAuction.connect(user2).amountDueForPurchase("20");

    await stablecoin.connect(user2).approve(newAuction, ethers.parseEther("100"));
    await newAuction.connect(user2).buyTokensWithStableCoin("20");

    expect(await newAuction.balances(user2.address)).to.equal(ethers.parseEther("20"));
    expect(await stablecoin.balanceOf(newAuction)).to.equal(amountDue.toString());

    await time.increaseTo(auctionParams.auctionEndTime + 60);
    await newAuction.connect(user2).claimPurchasedTokens();
    expect(await token.balanceOf(user2.address)).to.equal(ethers.parseUnits("20", 18));
    expect(await token.balanceOf(newAuction)).to.equal(ethers.parseUnits("480", 18));
  });

  it("should allow the creator to remove unbought tokens after the auction", async function () {
    const { user1, user2 } = await loadFixture(deployContractsFixture);
    const { newAuction, auctionParams } = await createAndFundAuction(user1);

    await newAuction.connect(user1).setSlope(ethers.parseEther("0.25"));
    const amountDue = await newAuction.connect(user2).amountDueForPurchase("20");

    await stablecoin.connect(user2).approve(newAuction, ethers.parseEther("100"));
    await newAuction.connect(user2).buyTokensWithStableCoin("20");

    await time.increaseTo(auctionParams.auctionEndTime + 60);

    await newAuction.connect(user2).claimPurchasedTokens();
    expect(await token.balanceOf(user2.address)).to.equal(ethers.parseUnits("20", 18));

    await newAuction.connect(user1).withdrawUnsoldTokens();
    expect(await token.balanceOf(user1.address)).to.equal(ethers.parseUnits("480", 18));
    expect(await token.balanceOf(newAuction)).to.equal(0);
  });
});
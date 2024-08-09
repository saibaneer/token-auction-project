import { expect } from "chai";
import { ethers } from "hardhat";
import {
  AuctionAsset,
  AuctionEntrypoint,
  AuctionFactory,
  PaymentERC20,
} from "../typechain-types";
import { createAuctionParameters } from "./unit-tests.test";
import { AuctionCreationParams, PricingLogic } from "./constants";
import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";

let auctionFactory: AuctionFactory;
let token: AuctionAsset;
let stablecoin: PaymentERC20;
let auctionContract: AuctionEntrypoint;
let auctionAddress1: string;

describe.only("Auction Factory", function () {
  beforeEach(async function () {
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
  });
  it("should allow the user update the master model", async function () {
    const AuctionModel0 = await ethers.getContractFactory("AuctionEntrypoint");
    const newAuctionModel0 = await AuctionModel0.deploy();

    await auctionFactory.updateMasterModel(await newAuctionModel0.getAddress());
    expect(await auctionFactory.masterAuctionEntryPoint()).to.equal(
      await newAuctionModel0.getAddress()
    );
  });
  it("should allow the user to create a new auction", async function () {
    const [owner, user1, user2] = await ethers.getSigners();
    const t1 = Date.now() + 60;
    const t2 = Date.now() + 60 * 60 * 24;
    const auctionParams: AuctionCreationParams = {
      tokenAddress: await token.getAddress(),
      numberOfTokens: ethers.parseEther("500"), // 1 token with 18 decimals
      startingPrice: ethers.parseEther("0.5"), // 0.5 ETH
      acceptedStable: await stablecoin.getAddress(), // Example stablecoin address
      creator: user1.address,
      auctionStartTime: Math.floor(Date.now() / 1000), // current timestamp in seconds
      auctionEndTime: Math.floor(Date.now() / 1000) + 3600, // current timestamp + 1 hour
      logic: PricingLogic.LinearFunction,
    };

    const auctionAddress = await auctionFactory
      .connect(owner)
      .createAuction.staticCall(auctionParams);
    auctionAddress1 = auctionAddress;
    await auctionFactory.connect(owner).createAuction(auctionParams);
    expect(auctionAddress).to.be.string;
  });
  it("should fund an auction", async function () {
    const [owner, user1, user2] = await ethers.getSigners();
    const t1 = Date.now() + 60;
    const t2 = Date.now() + 60 * 60 * 24;
    const auctionParams: AuctionCreationParams = {
      tokenAddress: await token.getAddress(),
      numberOfTokens: ethers.parseEther("500"), // 1 token with 18 decimals
      startingPrice: ethers.parseEther("0.5"), // 0.5 ETH
      acceptedStable: await stablecoin.getAddress(), // Example stablecoin address
      creator: user1.address,
      auctionStartTime: Math.floor(Date.now() / 1000), // current timestamp in seconds
      auctionEndTime: Math.floor(Date.now() / 1000) + 3600, // current timestamp + 1 hour
      logic: PricingLogic.LinearFunction,
    };

    const auctionAddress = await auctionFactory
      .connect(owner)
      .createAuction.staticCall(auctionParams);
    auctionAddress1 = auctionAddress;
    await auctionFactory.connect(user1).createAuction(auctionParams);
    expect(auctionAddress).to.be.string;

    const newAuction = await ethers.getContractAt(
      "AuctionEntrypoint",
      auctionAddress1
    );

    // console.log(await token.balanceOf(user1.address));
    await token
      .connect(user1)
      .approve(auctionAddress1, ethers.parseEther("500"));
    expect(await token.balanceOf(auctionAddress1)).to.equals(0);
    await newAuction.connect(user1).fundAuction();
    expect(await token.balanceOf(auctionAddress1)).to.equals(
      ethers.parseEther("500")
    );
  });
  it("should set the slope on a funded auction", async function () {
    const [owner, user1, user2] = await ethers.getSigners();
    const t1 = Date.now() + 60;
    const t2 = Date.now() + 60 * 60 * 24;
    const auctionParams: AuctionCreationParams = {
      tokenAddress: await token.getAddress(),
      numberOfTokens: ethers.parseEther("500"), // 1 token with 18 decimals
      startingPrice: ethers.parseEther("0.5"), // 0.5 ETH
      acceptedStable: await stablecoin.getAddress(), // Example stablecoin address
      creator: user1.address,
      auctionStartTime: Math.floor(Date.now() / 1000), // current timestamp in seconds
      auctionEndTime: Math.floor(Date.now() / 1000) + 3600, // current timestamp + 1 hour
      logic: PricingLogic.LinearFunction,
    };

    const auctionAddress = await auctionFactory
      .connect(owner)
      .createAuction.staticCall(auctionParams);
    auctionAddress1 = auctionAddress;
    await auctionFactory.connect(user1).createAuction(auctionParams);
    expect(auctionAddress).to.be.string;

    const newAuction = await ethers.getContractAt(
      "AuctionEntrypoint",
      auctionAddress1
    );

    // console.log(await token.balanceOf(user1.address));
    await token
      .connect(user1)
      .approve(auctionAddress1, ethers.parseEther("500"));
    expect(await token.balanceOf(auctionAddress1)).to.equals(0);
    await newAuction.connect(user1).fundAuction();
    expect(await token.balanceOf(auctionAddress1)).to.equals(
      ethers.parseEther("500")
    );

    expect(await newAuction.chargePerUnitToken()).to.equals(0);
    await newAuction.connect(user1).setSlope(ethers.parseEther("0.25"));
    expect(await newAuction.chargePerUnitToken()).to.equals(
      ethers.parseEther("0.25")
    );
  });
  it("should allow a user to enter auctions", async function () {
    const [owner, user1, user2] = await ethers.getSigners();
    const t1 = Date.now() + 60;
    const t2 = Date.now() + 60 * 60 * 24;
    const auctionParams: AuctionCreationParams = {
      tokenAddress: await token.getAddress(),
      numberOfTokens: ethers.parseEther("500"), // 1 token with 18 decimals
      startingPrice: ethers.parseEther("0.5"), // 0.5 ETH
      acceptedStable: await stablecoin.getAddress(), // Example stablecoin address
      creator: user1.address,
      auctionStartTime: Math.floor(Date.now() / 1000), // current timestamp in seconds
      auctionEndTime: Math.floor(Date.now() / 1000) + 3600, // current timestamp + 1 hour
      logic: PricingLogic.LinearFunction,
    };

    const auctionAddress = await auctionFactory
      .connect(owner)
      .createAuction.staticCall(auctionParams);
    auctionAddress1 = auctionAddress;
    await auctionFactory.connect(user1).createAuction(auctionParams);
    expect(auctionAddress).to.be.string;

    const newAuction = await ethers.getContractAt(
      "AuctionEntrypoint",
      auctionAddress1
    );

    // console.log(await token.balanceOf(user1.address));
    await token
      .connect(user1)
      .approve(auctionAddress1, ethers.parseEther("500"));
    expect(await token.balanceOf(auctionAddress1)).to.equals(0);
    await newAuction.connect(user1).fundAuction();
    expect(await token.balanceOf(auctionAddress1)).to.equals(
      ethers.parseEther("500")
    );

    expect(await newAuction.chargePerUnitToken()).to.equals(0);
    await newAuction.connect(user1).setSlope(ethers.parseEther("0.25"));
    expect(await newAuction.chargePerUnitToken()).to.equals(
      ethers.parseEther("0.25")
    );

    // console.log(auctionParams)
    // const buyTime = await time.increaseTo()
    const amountDue = await newAuction
      .connect(user2)
      .amountDueForPurchase("20");

    // await newAuction.connect(user2)
    // await stablecoin.mint(user2.address, ethers.parseUnits(amountDue.toString(), "wei"));
    expect(await newAuction.balances(user2.address)).to.equals(0);
    await stablecoin
      .connect(user2)
      .approve(auctionAddress1, ethers.parseEther("100"));
    await newAuction.connect(user2).buyTokensWithStableCoin("20");
    expect(await newAuction.balances(user2.address)).to.equals(ethers.parseEther("20"));
    expect(await stablecoin.balanceOf(newAuction)).to.equal(
      amountDue.toString()
    );

    // console.log("Auction contract holds a token balance of: ", await token.balanceOf(newAuction))
    // console.log("Auction contract holds a stable token balance of: ", await stablecoin.balanceOf(newAuction))
  });
  it("should allow user claim tokens after auction ends", async function () {
    const [owner, user1, user2] = await ethers.getSigners();
    const t1 = Date.now() + 60;
    const t2 = Date.now() + 60 * 60 * 24;
    const auctionParams: AuctionCreationParams = {
      tokenAddress: await token.getAddress(),
      numberOfTokens: ethers.parseEther("500"), // 1 token with 18 decimals
      startingPrice: ethers.parseEther("0.5"), // 0.5 ETH
      acceptedStable: await stablecoin.getAddress(), // Example stablecoin address
      creator: user1.address,
      auctionStartTime: Math.floor(Date.now() / 1000), // current timestamp in seconds
      auctionEndTime: Math.floor(Date.now() / 1000) + 3600, // current timestamp + 1 hour
      logic: PricingLogic.LinearFunction,
    };

    const auctionAddress = await auctionFactory
      .connect(owner)
      .createAuction.staticCall(auctionParams);
    auctionAddress1 = auctionAddress;
    await auctionFactory.connect(user1).createAuction(auctionParams);
    expect(auctionAddress).to.be.string;

    const newAuction = await ethers.getContractAt(
      "AuctionEntrypoint",
      auctionAddress1
    );

    // console.log(await token.balanceOf(user1.address));
    await token
      .connect(user1)
      .approve(auctionAddress1, ethers.parseEther("500"));
    expect(await token.balanceOf(auctionAddress1)).to.equals(0);
    await newAuction.connect(user1).fundAuction();
    expect(await token.balanceOf(auctionAddress1)).to.equals(
      ethers.parseEther("500")
    );

    expect(await newAuction.chargePerUnitToken()).to.equals(0);
    await newAuction.connect(user1).setSlope(ethers.parseEther("0.25"));
    expect(await newAuction.chargePerUnitToken()).to.equals(
      ethers.parseEther("0.25")
    );

    // console.log(auctionParams)
    // const buyTime = await time.increaseTo()
    const amountDue = await newAuction
      .connect(user2)
      .amountDueForPurchase("20");

    
    expect(await newAuction.balances(user2.address)).to.equals(0);
    await stablecoin
      .connect(user2)
      .approve(auctionAddress1, ethers.parseEther("100"));
    await newAuction.connect(user2).buyTokensWithStableCoin("20");
    expect(await newAuction.balances(user2.address)).to.equals(ethers.parseEther("20"));
    expect(await stablecoin.balanceOf(newAuction)).to.equal(
      amountDue.toString()
    );
    // console.log(await stablecoin.balanceOf(newAuction))

    expect(await token.balanceOf(user2)).to.equal(0)
    await time.increaseTo(auctionParams.auctionEndTime + 60);
    await newAuction.connect(user2).claimPurchasedTokens();
    expect(await token.balanceOf(user2.address)).to.equal(ethers.parseUnits("20", 18));
    expect(await token.balanceOf(newAuction)).to.equal(ethers.parseUnits("480", 18));
  });
  it("should allow the creator to remove unbought tokens after the auction", async function(){
    const [owner, user1, user2] = await ethers.getSigners();
    
    const auctionParams: AuctionCreationParams = {
      tokenAddress: await token.getAddress(),
      numberOfTokens: ethers.parseEther("500"), // 1 token with 18 decimals
      startingPrice: ethers.parseEther("0.5"), // 0.5 ETH
      acceptedStable: await stablecoin.getAddress(), // Example stablecoin address
      creator: user1.address,
      auctionStartTime: await time.latest() , // current timestamp in seconds
      auctionEndTime: await time.latest()  + 3600, // current timestamp + 1 hour
      logic: PricingLogic.LinearFunction,
    };

    const auctionAddress = await auctionFactory
      .connect(owner)
      .createAuction.staticCall(auctionParams);
    auctionAddress1 = auctionAddress;
    await auctionFactory.connect(user1).createAuction(auctionParams);
    expect(auctionAddress).to.be.string;

    const newAuction = await ethers.getContractAt(
      "AuctionEntrypoint",
      auctionAddress1
    );

    // console.log(await token.balanceOf(user1.address));
    await token
      .connect(user1)
      .approve(auctionAddress1, ethers.parseEther("500"));
    expect(await token.balanceOf(auctionAddress1)).to.equals(0);
    await newAuction.connect(user1).fundAuction();
    expect(await token.balanceOf(auctionAddress1)).to.equals(
      ethers.parseEther("500")
    );

    expect(await newAuction.chargePerUnitToken()).to.equals(0);
    await newAuction.connect(user1).setSlope(ethers.parseEther("0.25"));
    expect(await newAuction.chargePerUnitToken()).to.equals(
      ethers.parseEther("0.25")
    );

  
    const amountDue = await newAuction
      .connect(user2)
      .amountDueForPurchase("20");

    
    expect(await newAuction.balances(user2.address)).to.equals(0);
    await stablecoin
      .connect(user2)
      .approve(auctionAddress1, ethers.parseEther("100"));
    //   console.log("Auction opened: ", auctionParams.auctionStartTime);
    //   console.log("Now : ", Math.floor(Date.now() / 1000) )
    //   console.log("Now using hardhat time: ", await time.latest());
    //   console.log("Auction ends: ", auctionParams.auctionEndTime);
    await newAuction.connect(user2).buyTokensWithStableCoin("20");
    expect(await newAuction.balances(user2.address)).to.equals(ethers.parseEther("20"));
    expect(await stablecoin.balanceOf(newAuction)).to.equal(
      amountDue.toString()
    );

    expect(await token.balanceOf(user2)).to.equal(0)
    await time.increaseTo(auctionParams.auctionEndTime + 60);

    await newAuction.connect(user2).claimPurchasedTokens();
    expect(await token.balanceOf(user2.address)).to.equal(ethers.parseUnits("20", 18));
    expect(await token.balanceOf(newAuction)).to.equal(ethers.parseUnits("480", 18));

    // console.log("Token balance of Auction contract before payment: ", await token.balanceOf(newAuction))
    await newAuction.connect(user1).withdrawUnsoldTokens();
    expect(await token.balanceOf(user1)).to.equal(ethers.parseUnits("480", 18));
    expect(await token.balanceOf(newAuction)).to.equal(0);
  })
});

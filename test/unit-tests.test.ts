import {} from "../typechain-types";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";


// function createAuctionParameters()


describe("Unit Tests", function(){
    async function deployContractsFixture(){
        const [owner, user1, user2] = await ethers.getSigners();

        const AuctionModel0 = await ethers.getContractFactory("AuctionEntrypoint");
        const auctionModel0 = await AuctionModel0.deploy();
        

        const AuctionFactory = await ethers.getContractFactory("AuctionFactory");
        const auctionFactory = await AuctionFactory.deploy(await auctionModel0.getAddress());

        return { owner, user1, user2, auctionModel0, auctionFactory}
    }
})
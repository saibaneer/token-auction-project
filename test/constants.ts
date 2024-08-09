import { ethers } from "hardhat";

export enum PricingLogic {
    LinearFunction = 0,
    QuadraticFunction = 1,
    PolynomialFunction = 2
}

export interface AuctionCreationParams {
    tokenAddress: string;
    numberOfTokens: bigint;
    startingPrice: bigint;
    acceptedStable: string;
    creator: string;
    auctionStartTime: number; // assuming timestamp as a number (seconds since epoch)
    auctionEndTime: number;   // assuming timestamp as a number (seconds since epoch)
    logic: PricingLogic;
}

// const auctionParams: AuctionCreationParams = {
//     tokenAddress: "0x1234567890abcdef1234567890abcdef12345678",
//     numberOfTokens: ethers.parseEther("500"), // 1 token with 18 decimals
//     startingPrice: ethers.parseEther("0.5"),   // 0.5 ETH
//     acceptedStable: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcdef", // Example stablecoin address
//     creator: "0x1234567890abcdef1234567890abcdef12345678",
//     auctionStartTime: Math.floor(Date.now() / 1000), // current timestamp in seconds
//     auctionEndTime: Math.floor(Date.now() / 1000) + 3600, // current timestamp + 1 hour
//     logic: PricingLogic.LinearFunction
// };
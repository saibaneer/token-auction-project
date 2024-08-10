

# Auction Factory and Entrypoint Solidity Contracts

## Overview

This project consists of a set of Solidity contracts designed to create and manage token auctions using customizable pricing models. The core functionality is provided by the `AuctionFactory` and `AuctionEntrypoint` contracts, which utilize OpenZeppelin libraries and custom logic for linear and quadratic pricing of tokens.

### Features

- **Auction Factory**: Deploys new auction contracts using a minimal proxy pattern for efficiency.
- **Flexible Pricing Models**: Supports linear and quadratic pricing functions for token sales.
- **Token Purchase and Claim**: Users can purchase tokens during the auction using Ether or stablecoins, and claim their tokens after the auction ends.
- **Admin Controls**: The auction creator has the ability to withdraw remaining base tokens and unsold tokens after the auction ends.

## Contracts

### 1. `AuctionFactory`

The `AuctionFactory` contract is responsible for deploying new auction contracts using the clone pattern provided by the `Clones` library from OpenZeppelin. This ensures that each auction is deployed efficiently, saving on gas costs.

#### Key Functions:

- `createAuction(AuctionCreationParams memory _params)`: Creates a new auction contract based on the parameters provided.
- `updateMasterModel(address _newMasterModel)`: Updates the master model contract used for cloning.
- `getAllAuctionsCreated()`: Returns an array of all auctions created by the factory.

### 2. `AuctionEntrypoint`

The `AuctionEntrypoint` contract provides the primary interface for interacting with individual auctions. It supports the initialization of auction parameters, token purchases, and post-auction claims.

#### Key Functions:

- `initialize(AuctionCreationParams memory _params)`: Initializes the auction with the provided parameters.
- `fundAuction()`: Allows the auction creator to fund the auction with the specified tokens.
- `buyTokensWithStableCoin(uint256 unitsOfTokensToBuy)`: Allows users to purchase tokens using stablecoins.
- `claimPurchasedTokens()`: Allows users to claim their purchased tokens after the auction ends.
- `withdrawUnsoldTokens()`: Allows the auction creator to withdraw any unsold tokens after the auction ends.

### 3. Pricing Models

The auction system supports two different pricing models: **Linear** and **Quadratic**. These models determine how the price of each token increases as more tokens are sold.

#### Linear Pricing Model

In the **Linear Pricing Model**, the price of each subsequent token increases linearly based on a fixed increment. The total cost for purchasing tokens is calculated using the formula for the sum of an arithmetic series.

- **Formula**: 
  Total Cost = (Number of Tokens) * ((First Token Price + Last Token Price) / 2)
  where:
  - `First Token Price = startingBidPrice + (chargePerUnitToken * totalTokensSold)`
  - `Last Token Price = First Token Price + ((unitsOfTokensToBuy - 1) * chargePerUnitToken)`

This model is straightforward and predictable, making it suitable for auctions where a steady increase in token price is desired.

#### Quadratic Pricing Model

In the **Quadratic Pricing Model**, the price of tokens increases quadratically. This model is more aggressive, with prices rising faster as more tokens are sold. The total cost is determined using the sum of squares formula, which reflects the increasing difficulty of acquiring additional tokens.

- **Formula**: 
  Total Cost = (amount * startingBidPrice) + (priceMultiplier * sumOfSquares(n, m))
  where:
  - `n` is the number of tokens sold before this purchase.
  - `m` is the total number of tokens after the purchase.
  - `sumOfSquares(n, m)` calculates the sum of squares between these two points.

This model is ideal for creating a steeper increase in prices, incentivizing early participation in the auction.

## Installation

To work with this project, ensure that you have the following tools installed:

- [Node.js](https://nodejs.org/)
- [npm](https://www.npmjs.com/)
- [Hardhat](https://hardhat.org/)

### Dependencies

Install the necessary dependencies using npm:

```bash
npm install
```

This will install the following required packages:

- OpenZeppelin Contracts
- Hardhat
- EthereumJS
- Ethers.js

## Compilation

Compile the contracts using Hardhat:

```bash
npx hardhat compile
```

## Deployment

Deploy the contracts to a local or test Ethereum network using Hardhat. You will need to set up your network configuration in `hardhat.config.js`.

```bash
npx hardhat run scripts/deploy.js --network <network-name>
```

Replace `<network-name>` with the appropriate network, such as `localhost`, `sepolia`, or `mainnet`.

## Usage

### Creating an Auction

To create an auction, call the `createAuction` function from the `AuctionFactory` contract with the required parameters.

```solidity
AuctionCreationParams memory params = AuctionCreationParams({
    chargePerUnitTokenInEth: ...,
    tokenAddress: ...,
    numberOfTokens: ...,
    startingPrice: ...,
    acceptedStable: ...,
    creator: ...,
    auctionStartTime: ...,
    auctionEndTime: ...,
    logic: PricingLogic.LinearFunction // or PricingLogic.QuadraticFunction
});

address auctionAddress = auctionFactory.createAuction(params);
```

### Participating in an Auction

Users can participate in an auction by purchasing tokens using Ether or stablecoins through the `AuctionEntrypoint` contract.

- **Buy Tokens with Stablecoin**: Call the `buyTokensWithStableCoin` function with the number of tokens to buy.
- **Claim Tokens**: After the auction ends, call `claimPurchasedTokens` to claim your tokens.

### Managing Auctions

Auction creators can manage the auction by:

- **Funding the Auction**: Use the `fundAuction` function to deposit the tokens to be sold.
- **Withdrawing Unsold Tokens**: After the auction ends, call `withdrawUnsoldTokens` to retrieve any unsold tokens.

## Security Considerations

- **Reentrancy Protection**: Ensure that functions interacting with external contracts are secured against reentrancy attacks.
- **Access Control**: Critical functions, such as withdrawing funds or unsold tokens, should be restricted to the auction creator or owner.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

This updated `README.md` now includes detailed descriptions of both the Linear and Quadratic pricing models, providing a better understanding of how these models influence the auction dynamics. Feel free to customize further as needed!


```mermaid
classDiagram
    class Ownable {
        <<abstract>>
    }
    
    class ModelVerifier {
        <<abstract>>
    }
    
    Ownable <|-- AuctionFactory
    ModelVerifier <|-- AuctionFactory

    AuctionFactory --> AuctionEntrypoint : Creates
    AuctionEntrypoint --> InternalAuction : Inherits
    InternalAuction --> ISingleAuction : Implements
    InternalAuction --> Initializable : Inherits
    InternalAuction --> Storage : Inherits

    AuctionEntrypoint <|-- LinearPricingLogicLib
    AuctionEntrypoint <|-- QuadraticPricingLogicLib

    ISingleAuction <|.. Storage
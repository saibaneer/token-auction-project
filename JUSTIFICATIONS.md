1. Why the factory approach?
   When creating a system that offers a service such as a token auction service, it is important to reason that
   this system may indeed serve more than one user. Creating a single contract would be too simplistic, and would
   not scale effectively. Thus, it is always best to think that multiple users may need the same service, and thus
   one should plan the architecture to suport such.

   1b. Why use clones?
   When using factory patterns, the logic and storage of what one is creating is often the same. However, if one deployed a new contract with fresh bytecode each time they initiated a new token auction, this would bloat the
   size of the factory contract, and would quickly increase the chances of running into a spurious dragon error.
   Clones (ERC 1167) addresses this issue by allowing us create copies of a model which has its own storage, but uses the implementation on the main model. The outcome of this is lighter weight contracts, the current size of the Auction contract is approx 5.2KB, while the factory contract is less than 3.4 KB. This makes it cheaper to call the
   create auction function for users.

2. Why use libraries?
   The logic for estimating price seems to implementable when all the paramters are passed into it. Thus, it looks a lot like a pure function. This allows us to refactor the pricing logic into its own library, thus reducing the size of the contract. Also if the admin decided they wanted to change the pricing logic, the could update call the updateModel on the factory contract and pass in a new auction type contract that would integrate new libraries, thus making the system somewhat modular.

3. Why use the linear bonding model?
   It was the easiest and most gas-efficient way to implement an auction of ERc20 tokens where the price goes up as more orders are filled. The linear model is also the simplest type of such a model, as it is built on the core idea of y = mx + c. Where y is the price of the token, m is the rate of change, x is the qty of token at that point in time, and c is the starting price of the auction. By finding the area under the line betweet y0 and y1, one could estimate the price(increase) per unit token, for each time a unit of token has been purchased.

4. Why use the quadratic bonding model?
   To create some optionality for the user, should they chose to have the price of the token rise faster exponentially as more units of tokens are sold. This model uses the sum of 2 squares, and similarly estimates the area under the curve to measure the marginal increase in price per each token bought. Total Cost = amount _ startingBidPrice + priceMultiplier _ sumOfSquares(n, m). Where n is number of tokens sold before the user buys a single unit, and m is the number of tokens sold after the user has filled their order.

5. Why use Stablecoins for payments instead of ETH?
   Hardhat Runtime Environment gives me 100 ETH per account. For values of m, larger than 0.25, the cost of tokens could rise very quickly thus eating up my ETH allotment. So in other to give myself maximum flexibility to demonstrate the solution, I created a mock stable coin that is denominated to 18 decimals. Naturally, to implement this in the real world I would need to account from the fact that some stable coins use 6 decimal places such as USDC. Or alternatively, I would switch to ETH in the real world and alter the logic slightly to receive ETH payments.
   
6. What would I improve if I had more time?
   The verification logic for the updateModel function on the factory contract. In my desire to revert early, I didn't fully implement this part, as it requires more robust testing.

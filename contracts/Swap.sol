// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "https://github.com/aave/aave-protocol/contracts/Flashloan.sol";
import "https://github.com/Uniswap/uniswap-v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/gmx/gmx/contracts/GMX.sol";

contract FlashloanArbitrage {
    // Address of the AAVE flashloan contract
    address public flashloan;
    // Address of the Uniswap router contract
    address public uniswapRouter;
    // Address of the GMX contract
    address public gmx;

    constructor(
        address _flashloan,
        address _uniswapRouter,
        address _gmx
    ) public {
        flashloan = _flashloan;
        uniswapRouter = _uniswapRouter;
        gmx = _gmx;
    }

    /**
     * Execute a flashloan arbitrage trade using AAVE, Uniswap, and GMX
     *
     * @param _from - The address that will be borrowing the flashloan
     * @param _fromToken - The token to be borrowed in the flashloan
     * @param _fromAmount - The amount of the token to be borrowed
     * @param _toToken - The token to be bought with the borrowed funds
     * @param _gmxToken - The GMX token to be used in the trade
     * @param _minProfit - The minimum profit that must be achieved for the trade to be executed
     */
    function executeTrade(
        address _from,
        address _fromToken,
        uint256 _fromAmount,
        address _toToken,
        address _gmxToken,
        uint256 _minProfit
    ) public {
        // Borrow the flashloan from AAVE
        (bool success,) = flashloan.flashloan(
            _from,
            _fromToken,
            _fromAmount
        );
        require(success, "Failed to borrow flashloan");

        // Call the Uniswap router to get the exchange rate for the trade
        IUniswapV2Router02 router = IUniswapV2Router02(uniswapRouter);
        uint256 buyAmount = router.getAmountsOut(_fromAmount, _fromToken, _toToken).amountOut;

        // Check if the trade will be profitable
        uint256 profit = buyAmount.mul(_minProfit).div(10 ** 18);
        require(buyAmount.add(profit) <= _fromAmount, "Trade not profitable");

        // Execute the trade on Uniswap
        router.swapExactTokensForTokens(
            _fromAmount,
            _fromToken,
            _toToken,
            _from,
            address(0)
        );

        // Call the GMX contract to settle the trade
        GMX gmxContract = GMX(gmx);
        gmxContract.executeTrade(_gmxToken, _toToken, buyAmount, _from);
    }
}
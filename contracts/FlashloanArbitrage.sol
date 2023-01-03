pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT



contract FlashloanArbitrage {
    using SafeMath for uint256;

    // Address of the AAVE flashloan contract
    address public flashloan;
    // Address of the Uniswap router contract
    address public uniswapRouter;

    constructor(
        address _flashloan,
        address _uniswapRouter
    ) public {
        flashloan = _flashloan;
        uniswapRouter = _uniswapRouter;
    }

    /**
     * Execute a flashloan arbitrage trade using AAVE and any exchange
     *
     * @param _from - The address that will be borrowing the flashloan
     * @param _fromToken - The token to be borrowed in the flashloan
     * @param _fromAmount - The amount of the token to be borrowed
     * @param _toToken - The token to be bought with the borrowed funds
     * @param _exchange1 - The address of the exchange contract to be used in the trade
     * @param _exchange2 - The address of the exchange contract to be used in the trade
     * @param _exchange1Interface - The name of the exchange interface to be used in the trade (e.g. "IUniswapV3Router")
     * @param _exchange2Interface - The name of the exchange interface to be used in the trade (e.g. "IUniswapV3Router")
     * @param _minProfit - The minimum profit that must be achieved for the trade to be executed
     */
    function executeTrade(
        address _from,
        address _fromToken,
        uint256 _fromAmount,
        address _toToken,
        address _exchange1,
        address _exchange2,
        string memory _exchange1Interface,
        string memory _exchange2Interface,
        uint256 _minProfit
    ) public {
        // Borrow the flashloan from AAVE
        (bool success,) = flashloan.flashloan(
            _from,
            _fromToken,
            _fromAmount
        );
        require(success, "Failed to borrow flashloan");

        // Call the first exchange contract to get the exchange rate for the trade
        bytes32 selector1 = bytes32(keccak256("getAmountsOut(uint256,address,address)"));
        (uint256 buyAmount,) = address(_exchange1).call(
            selector1,
            abi.encodePacked(_fromAmount, _fromToken, _toToken)
        );

        // Check if the trade will be profitable
        uint256 profit = buyAmount.mul(_minProfit).div(10 ** 18);
        require(buyAmount.add(profit) <= _fromAmount, "Trade not profitable");

        // Execute the trade on the first exchange
        bytes32 exchangeSelector1 = bytes32(keccak256("swapExactTokensForTokens(uint256,address,address,address,uint256)"));
        (bool exchangeSuccess,) = address(_exchange1).call(
            exchangeSelector1,
            abi.encodePacked(_fromAmount, _fromToken, _toToken, _from, 0)
        );
        require(exchangeSuccess, "Failed to execute trade on exchange 1");

        // Sell the resulting token on the second exchange
        bytes32 selector2 = bytes32(keccak256("getAmountsOut(uint256,address,address)"));
        (uint256 sellAmount,) = address(_exchange2).call(
            selector2,
            abi.encodePacked(buyAmount, _toToken, _fromToken)
        );

        // Execute the trade on the second exchange
        bytes32 exchangeSelector2 = bytes32(keccak256("swapExactTokensForTokens(uint256,address,address,address,uint256)"));
        (bool exchangeSuccess,) = address(_exchange2).call(
            exchangeSelector2,
            abi.encodePacked(buyAmount, _toToken, _fromToken, _from, 0)
        );
        require(exchangeSuccess, "Failed to execute trade on exchange 2");

        // Repay the flashloan to AAVE
        flashloan.flashrepay(_from, _fromAmount);
    }
}
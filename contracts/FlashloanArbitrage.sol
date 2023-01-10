pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

contract FlashloanArbitrage {

    /**
     * Execute a flashloan arbitrage trade using AAVE and any two exchanges
     *
     * @param _from - The address that will be borrowing the flashloan
     * @param _fromToken - The token to be borrowed in the flashloan
     */

    function executeTriangularArbitrage(
        address _from,
        address _token1,
        address _token2,
        address _token3,
        uint256 _amount1,
        address _exchange1,
        address _exchange2,
        address _exchange3,
        string memory _exchange1Interface,
        string memory _exchange2Interface,
        string memory _exchange3Interface,
        uint256 _minProfit
    ) public {
        // Borrow the flashloan from AAVE
        (bool success,) = flashloan.flashloan(
            _from,
            _token1,
            _amount1
        );
        require(success, "Failed to borrow flashloan");

        // Call the first exchange contract to get the exchange rate for the first trade
        bytes32 selector1 = bytes32(keccak256("getAmountsOut(uint256,address,address)"));
        (uint256 buyAmount,) = address(_exchange1).call(
            selector1,
            abi.encodePacked(_amount1, _token1, _token2)
        );

        // Check if the first trade will be profitable
        uint256 profit = buyAmount.mul(_minProfit).div(10 ** 18);
        require(buyAmount.add(profit) <= _amount1, "Trade 1 not profitable");

        // Execute the first trade on the first exchange
        bytes32 exchangeSelector1 = bytes32(keccak256("swapExactTokensForTokens(uint256,address,address,address,uint256)"));
        (bool exchangeSuccess,) = address(_exchange1).call(
            exchangeSelector1,
            abi.encodePacked(_amount1, _token1, _token2, _from, 0)
        );
        require(exchangeSuccess, "Failed to execute trade 1 on exchange 1");

        // Call the second exchange contract to get the exchange rate for the second trade
        bytes32 selector2 = bytes32(keccak256("getAmountsOut(uint256,address,address)"));
        (uint256 buyAmount,) = address(_exchange2).call(
            selector2,
            abi.encodePacked(buyAmount, _token2, _token3)
        );

        // Check if the second trade will be profitable
        profit = buyAmount.mul(_minProfit).div(10 ** 18);
        require(buyAmount.add(profit) <= _amount1, "Trade 2 not profitable");

        // Execute the second trade on the second exchange
        bytes32 exchangeSelector2 = bytes32(keccak256("swapExactTokensForTokens(uint256,address,address,address,uint256)"));
        (bool exchangeSuccess,) = address(_exchange2).call(
            exchangeSelector2,
            abi.encodePacked(buyAmount, _token2, _token3, _from, 0)
        );
        require(exchangeSuccess, "Failed to execute trade 2 on exchange 2");

        // Call the third exchange contract to get the exchange rate for the third trade
        bytes32 selector3 = bytes32(keccak256("getAmountsOut(uint256,address,address)"));
        (uint256 sellAmount,) = address(_exchange3).call(
            selector3,
            abi.encodePacked(buyAmount, _token3, _token1)
        );

        // Check if the third trade will be profitable
        profit = sellAmount.mul(_minProfit).div(10 ** 18);
        require(sellAmount.add(profit) >= _amount1, "Trade 3 not profitable");

        // Execute the third trade on the third exchange
        bytes32 exchangeSelector3 = bytes32(keccak256("swapExactTokensForTokens(uint256,address,address,address,uint256)"));
        (bool exchangeSuccess,) = address(_exchange3).call(
            exchangeSelector3,
            abi.encodePacked(buyAmount, _token3, _token1, _from, 0)
        );
        require(exchangeSuccess, "Failed to execute trade 3 on exchange 3");

        // Repay the flashloan to AAVE
        flashloan.flashrepay(_from, _amount1);
    }
}
pragma solidity 0.8.17;
// SPDX-License-Identifier: MIT

import {IUniswapV3Router} from "@uniswap/v3-core/contracts/IUniswapV3Router.sol";
import "https://github.com/Uniswap/contracts/blob/main/contracts/SushiSwapV2.sol";


contract Exchange {
    IUniswapV3Router public uniswapRouter;
    SushiSwapV2 public sushiswapRouter;

    constructor(address _uniswapRouter, address _sushiswapRouter) {
        uniswapRouter = IUniswapV3Router(_uniswapRouter);
        sushiswapRouter = SushiSwapV2(_sushiswapRouter);
    }

    function uniswapTrade(address tokenIn, address tokenOut, uint256 amountIn) public payable {
        // Prepare variables for the trade
        address payable to = address(this);
        address payable feeTo = address(0);
        uint256 deadline = block.timestamp + 30 minutes;
        uint256[] memory path = new uint256[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        // Execute the trade
        (uint[] memory amountsOut, uint[] memory fees) = router.executeTrade(
            tokenIn,
            amountIn,
            tokenOut,
            to,
            feeTo,
            deadline,
            path
        );

        // Check if the trade was successful
        require(amountsOut.length == 2, "Invalid trade");

        // Send the received tokens to the recipient
        Token(tokenOut).transfer(amountsOut[1]);
    }

    function sushiswapTrade(address tokenIn, address _tokenOut, uint256 _amountIn) public {
        // Execute trade
        sushiswapRouter.swap(
            _tokenIn, _amountIn,
            _tokenOut, msg.sender,
            0
        );
    }
}
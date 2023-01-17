pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

// import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
// import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
// import "https://github.com/sushiswap/sushiswap-v2-core/contracts/interfaces/ISushiSwapV2Router02.sol";

// uniswapV3 contracts
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';

contract Exchange {
    ISwapRouter public uniswapV3Router;
    // IUniswapV2Router02 uniswapRouterV2;
    // ISushiSwapV2Router02 sushiswapRouter;


    constructor(address _uniswapV3Router) {
        uniswapV3Router = ISwapRouter(_uniswapV3Router);
        // uniswapV2Router = IUniswapV3Router(_uniswapV2Router);
        // sushiswapRouter = SushiSwapV2(_sushiswapRouter);
    }

    // function uniswapV2Trade(address tokenIn, address tokenOut, uint256 amountIn) public payable {
       
    // }

    function uniswapV3Trade(address tokenIn, address tokenOut, uint256 amountIn) public payable {
       uint256 amountOutMin;


    }

    // function sushiswapTrade(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) public {
    //     address pair = IUniswap;
    //     address[] memory path = new address[](2);
    //     path[0] = _tokenIn;
    //     path[1] = _tokenOut;

    //     sushiswapRouter.swapExactTokensForTokens(
    //         _amountIn,
    //         _amountOutMin,
    //         path,
    //         _to,
    //         block.timestamp
    //     );
    // }
}
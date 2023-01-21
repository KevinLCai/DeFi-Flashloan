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
    uint24 public constant poolFee = 3000;


    constructor(address _uniswapV3Router) {
        uniswapV3Router = ISwapRouter(_uniswapV3Router);
        // uniswapV2Router = IUniswapV3Router(_uniswapV2Router);
        // sushiswapRouter = SushiSwapV2(_sushiswapRouter);
    }

    function getAmountOutMin(uint256 _amountIn) internal view returns (uint256) {
        // adjust gas approximation before deployment

        // change 1 to exchange 2 token price 
        return (_amountIn + (1 * block.gaslimit)) / 1;
    }

    // function uniswapV2Trade(address tokenIn, address tokenOut, uint256 amountIn) public payable {
       
    // }

    function uniswapV3Trade(address _tokenIn, address _tokenOut, uint256 _amountIn, bool _firstTrade) public payable {
        uint256 amountOutMin;
        if (_firstTrade) {
            amountOutMin = getAmountOutMin(_amountIn);
        } else {
            amountOutMin = _amountIn;
        }

        

        ISwapRouter.ExactInputSingleParams memory params = 
            ISwapRouter.ExactInputSingleParams({
                tokenIn: _tokenIn,
                tokenOut: _tokenOut,
                fee: poolFee,
                recipient: msg.sender,
                deadline:block.timestamp,
                amountIn: _amountIn,
                amountOutMinimum: amountOutMin,
                sqrtPriceLimitX96:0
            });
        
        uint256 amountOut = uniswapV3Router.exactInputSingle(params);

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
pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Exchange.sol";

contract Flashloan is FlashLoanSimpleReceiverBase, Exchange(0xE592427A0AEce92De3Edee1F18E0157C05861564) {
    address payable owner;
    address exchange1;
    address exchange2;
    address token1;
    address token2;

    constructor(IPoolAddressesProvider _provider) FlashLoanSimpleReceiverBase(_provider) {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    /**
     * Gets us the balance of an ERC20 stored in this contract (profits)
     */
    function getBalance(address _tokenAddress) external view returns(uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    /**
     * Withdraw profits
     */
    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function getGasPrice() public view returns (uint256) {
        return block.gaslimit;
    }

    /**
     * Requests flashloan from aave
     */
    function requestFlashloan(
        address _token1,
        address _token2,
        address _exchange1,
        address _exchange2,
        uint256 _amount
    ) public {
        token1 = _token1;
        token2 = _token2;
        exchange1 = _exchange1;
        exchange2 = _exchange2;

        address receiverAddress = address(this);
        address asset = _token1;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress, 
            asset, 
            amount, 
            params, 
            referralCode
        );
    }

    /**
     * Selects the right exhange to make a trade with
     */
    function exchangeTokens(address _from, address _to, uint256 _amountIn, address _exchange) internal returns (bool) {
        if (_exchange == address(0x1F98431c8aD98523631AE4a59f267346ea31F984)) {
            uniswapV3Trade(_from, _to, _amountIn);
        } 
        // else if (_exchange == "0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506") {
        //     sushiswapTrade(_from, _to, _amountIn, _amountOutMin);
        // }

        // below statement will be changed to check trades went through
        require(true && true);
        return true;
    }

    /**
     * Automatically triggered once flashloan is received
     */
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {

        

        // double check this amount - should it be less to reduce slippage?

        //exchanges token1 for token2 on exchange1

        // swap1 = 
        exchangeTokens(token1, token2, amount, exchange1);

        // exchanges token2 for token1 on exchange2
        // swap2 = 
        exchangeTokens(token2, token1, amount, exchange2);

        // ensure enough funds to pay flashloan + premiums
        uint256 amountOwed = amount + premium;
        IERC20(token1).approve(address(POOL), amountOwed);

        // change return value based on if the flashloan is successful
        return true;
    }

    receive() external payable {}
}
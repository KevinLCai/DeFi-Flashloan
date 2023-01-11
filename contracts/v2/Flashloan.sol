pragma solidity 0.8.17;
// SPDX-License-Identifier: MIT

import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

contract Flashloan is FlashLoanSimpleReceiverBase {
    address payable owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    function getBalance(address _tokenAddress) external view returns(uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function requestFlashloan(address _token, uint256 _amount) public {
        address receiverAddress = address(this);
        address asset = _token;
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

    function executeOperation(
        address token1,
        address token2,
        uint256 amount,
        address exchange1,
        address exchange2,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        // logic

        //exchanges token1 for token2 on exchange1

        // exchanges token2 for token1 on exchange2

        // ensure enough funds to pay flashloan + premiums

        uint256 amountOwed = amount + premium;
        IERC20(token1).approve(address(POOL), amountOwed);
    }

    receive() external payable {}
}
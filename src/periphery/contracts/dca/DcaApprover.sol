// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {ISwapRouter} from 'contracts/interfaces/ISwapRouter.sol';
import 'contracts/NonfungiblePositionManager.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import 'hardhat/console.sol';
import '../libraries/TransferHelper.sol';

struct Order {
    address user;
    address tokenIn;
    address tokenOut;
    uint256 amountIn;
    uint256 amountOutMin;
    uint256 period;
    uint256 lastExecution;
    uint256 totalExecutions;
    uint256 totalAmountIn;
    uint256 totalAmountOut;
    uint256 createdAt;
    bool stopped;
    address approver;
}

interface ISpiritDCA {
    function ordersById(uint256) external returns (Order memory);
}

contract SpiritDcaApprover is Ownable {
	ISwapRouter public router;
	ERC20 public usdc;
	ERC20 public tresory;

	uint256 public id;
    address public dca;
    address public user;
    address public tokenIn;

    //	Here hardcode some values to avoid any manipulation of the contract
	constructor(uint256 _id, address _user, address _tokenIn) {
		id = _id;
        dca = msg.sender;
        user = _user;
        tokenIn = _tokenIn;
	}

    function executeOrder() public {
        require(msg.sender == dca, 'Only DCA can execute order.');
        Order memory order = ISpiritDCA(dca).ordersById(id);

		require(block.timestamp - order.lastExecution >= order.period, 'Period not elapsed.');
        require(!order.stopped, 'Order is stopped.');

        TransferHelper.safeTransferFrom(tokenIn, user, dca, order.amountIn);
    }
}
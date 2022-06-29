// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import '../../IAlgebraVirtualPoolBase.sol';

interface IAlgebraEternalVirtualPool is IAlgebraVirtualPoolBase {
    function setRates(uint128 rate0, uint128 rate1) external;

    function addRewards(uint256 token0Amount, uint256 token1Amount) external;

    function getInnerRewardsGrowth(int24 bottomTick, int24 topTick)
        external
        view
        returns (uint256 rewardGrowthInside0, uint256 rewardGrowthInside1);

    /**
     * @dev This function is called when anyone farms their liquidity. The position in a virtual pool
     * should be changed accordingly
     * @param bottomTick The bottom tick of a position
     * @param topTick The top tick of a position
     * @param liquidityDelta The amount of liquidity in a position
     * @param tick The current tick in the main pool
     */
    function applyLiquidityDeltaToPosition(
        uint32 currentTimestamp,
        int24 bottomTick,
        int24 topTick,
        int128 liquidityDelta,
        int24 tick
    ) external;

    /**
     * @dev This function is used to calculate the seconds per liquidity inside a certain position
     * @param bottomTick The bottom tick of a position
     * @param topTick The top tick of a position
     * @return innerSecondsSpentPerLiquidity The seconds per liquidity inside the position
     */
    function getInnerSecondsPerLiquidity(int24 bottomTick, int24 topTick)
        external
        view
        returns (uint160 innerSecondsSpentPerLiquidity);
}

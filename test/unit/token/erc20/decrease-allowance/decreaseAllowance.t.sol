// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { stdError } from "forge-std/Test.sol";

import { ERC20UnitTest } from "../ERC20UnitTest.t.sol";

contract ERC20__DecreaseAllowance__CalculationUnderflowsUint256 is ERC20UnitTest {
    /// @dev it should revert.
    function testCannotDecreaseAllowance(address spender, uint256 value) external {
        vm.assume(spender != address(0));
        vm.assume(value > 0);

        vm.expectRevert(stdError.arithmeticError);
        dai.decreaseAllowance(spender, value);
    }
}

contract CalculationDoesNotUnderflowUint256 {}

contract ERC20__DecreaseAllowance is ERC20UnitTest, CalculationDoesNotUnderflowUint256 {
    /// @dev it should decrease the allowance.
    function testDecreaseAllowance(
        address spender,
        uint256 value0,
        uint256 value1
    ) external {
        vm.assume(spender != address(0));
        vm.assume(value0 > 0);
        vm.assume(value1 <= value0);

        // Increase the allowance so that we have what to decrease below.
        dai.increaseAllowance(spender, value0);

        // Run the test.
        dai.decreaseAllowance(spender, value1);
        uint256 actualAllowance = dai.allowance(users.alice, spender);
        uint256 expectedAllowance = value0 - value1;
        assertEq(actualAllowance, expectedAllowance);
    }

    /// @dev it should emit an Approval event.
    function testDecreaseAllowance__Event(
        address spender,
        uint256 value0,
        uint256 value1
    ) external {
        vm.assume(spender != address(0));
        vm.assume(value0 > 0);
        vm.assume(value1 <= value0);

        // Increase the allowance so that we have what to decrease below.
        dai.increaseAllowance(spender, value0);

        // Run the test.
        vm.expectEmit(true, true, false, true);
        uint256 expectedAllowance = value0 - value1;
        emit Approval(users.alice, spender, expectedAllowance);
        dai.decreaseAllowance(spender, value1);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @notice 工具链冒烟示例（forge init 默认示例）。
/// 周1 按 GUIDE 创建 FixedPointMath.sol 等真实合约后，删除本文件与本测试。
contract Counter {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}

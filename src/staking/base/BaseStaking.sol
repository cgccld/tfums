// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Currency} from "src/libraries/LibCurrency.sol";
import {Recoverable} from "src/recoverable/Recoverable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract BaseStaking {
  Currency rewardToken;
  Currency stakingToken;

  uint256 public periodFinish = 0;
  uint256 public rewardRate = 0;
  uint256 public rewardsDuration = 7 days;
  uint256 public lastUpdateTime;
  uint256 public rewardPerTokenStored;

  mapping(address => uint256) public userRewardPerTokenPaid;
  mapping(address => uint256) public rewards;

  uint256 private _totalSupply;
  mapping(address => uint256) private _balances;

  /* ========== VIEWS ========== */
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  function lastTimeRewardApplicable() public view returns (uint256) {
    return block.timestamp < periodFinish ? block.timestamp : periodFinish;
  }

  function rewardPerToken() public view returns (uint256) {
    if (_totalSupply == 0) {
      return rewardPerTokenStored;
    }

    uint256 lastTimeRewardApply = lastTimeRewardApplicable();
    uint256 rewardPerTokenAdditional = ((lastTimeRewardApply - lastUpdateTime) * rewardRate * 1e18) / _totalSupply;

    return rewardPerTokenStored + rewardPerTokenAdditional;
  }

  function earned(address account) public view returns (uint256) {
    return _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
  }

  function getRewardForDuration() external view returns (uint256) {
    return rewardRate.mul(rewardsDuration);
  }

  function stake(uint256 amount_) external {}

  function withdraw(uint256 amount_) external {}

  function claimReward() external {}

  function exit() external {
    withdraw();
    claimReward();
  }
}

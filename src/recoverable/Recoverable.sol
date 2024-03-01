// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Currency} from "../libraries/LibCurrency.sol";

/**
 * @title Recoverable
 * @dev Abstract contract providing a mechanism for recovering ERC20 tokens.
 */
abstract contract Recoverable {
  /**
   * @dev Emitted when tokens are recovered from the contract.
   * @param by The address initiating the token recovery.
   * @param token The ERC20 token being recovered.
   * @param amount The amount of tokens being recovered.
   */
  event TokenRecovery(address indexed by, Currency indexed token, uint256 amount);

  /**
   * @dev Recovers ERC20 tokens from the contract and transfers them to the specified receiver.
   * @param token The ERC20 token to recover.
   * @param receiver The address to receive the recovered tokens.
   */
  function _recoverToken(Currency token, address receiver) internal virtual {
    // Get the balance of the contract in the specified ERC20 token.
    uint256 selfBalance = token.selfBalance();

    // Transfer the entire balance of the ERC20 token to the specified receiver.
    token.transfer(receiver, selfBalance);

    // Emit an event to log the token recovery.
    emit TokenRecovery(receiver, token, selfBalance);
  }
}

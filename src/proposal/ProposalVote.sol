// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IProposalVote} from "./IProposalVote.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

abstract contract ProposalVote is IProposalVote {
  using EnumerableSet for *;

  uint256 private __numConfirmationsRequired;
  uint256 private __transactionExpirationTime;

  EnumerableSet.AddressSet private __voters;
  EnumerableSet.UintSet private __transactionIds;

  mapping(uint256 transactionId => Transaction) private __transactions;
  mapping(uint256 transactionId => mapping(address voter => bool)) private __isConfirmed;

  modifier onlyVoter() {
    if (!__voters.contains(msg.sender)) {
      revert NAV(msg.sender);
    }
    _;
  }

  modifier transactionExists(uint256 transactionId_) {
    if (__transactionIds.contains(transactionId_)) {
      revert TNE(transactionId_);
    }
    _;
  }

  modifier notExecuted(uint256 transactionId_) {
    if (__transactions[transactionId_].executed) {
      revert TAE(transactionId_);
    }
    _;
  }

  modifier notConfirmed(uint256 transactionId_) {
    if (__isConfirmed[transactionId_][msg.sender]) {
      revert TAC(transactionId_, msg.sender);
    }
    _;
  }

  // read
  function getVoters() external view returns (address[] memory voters) {
    voters = __voters.values();
  }

  function getTransactions() external view returns (uint256[] memory transactionIds) {
    transactionIds = __transactionIds.values();
  }

  function getTransactionDetails(uint256 transactionId_) external view returns (Transaction memory transaction) {
    transaction = __transactions[transactionId_];
  }

  // write
  function submitTransaction(address to_, uint256 value_, bytes memory data_) external onlyVoter {
    uint256 transactionId = block.timestamp;

    __transactionIds.add(transactionId);
    __transactions[transactionId] =
      Transaction({to: to_, value: value_, data: data_, executed: false, numConfirmations: 0});

    emit SubmitTransaction(msg.sender, transactionId, to_, value_, data_);
  }

  function confirmTransaction(uint256 transactionId_)
    external
    transactionExists(transactionId_)
    notExecuted(transactionId_)
    notConfirmed(transactionId_)
  {
    Transaction storage transaction = __transactions[transactionId_];

    address voter = msg.sender;
    transaction.numConfirmations += 1;
    __isConfirmed[transactionId_][voter] = true;

    emit ConfirmTransaction(voter, transactionId_);
  }

  function revokeConfirmation(uint256 transactionId_)
    external
    transactionExists(transactionId_)
    notExecuted(transactionId_)
  {
    Transaction storage transaction = __transactions[transactionId_];

    address voter = msg.sender;

    if (!__isConfirmed[transactionId_][voter]) {
      revert TNC(transactionId_, voter);
    }

    transaction.numConfirmations -= 1;
    __isConfirmed[transactionId_][voter] = false;

    emit RevokeConfirmation(voter, transactionId_);
  }

  function executeTransaction(uint256 transactionId_) external {
    Transaction storage transaction = __transactions[transactionId_];

    if (transaction.numConfirmations < __numConfirmationsRequired) {
      revert CNE(transactionId_);
    }

    transaction.executed = true;

    (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);
    require(success, "Execution failed");

    emit ExecuteTransaction(msg.sender, transactionId_);
  }
}

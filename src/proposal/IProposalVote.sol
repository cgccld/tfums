// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IProposalVote {
  error NAV(address voter); // not authority to vote
  error CNE(uint256 transactionId); // transaction cannot execute
  error TNE(uint256 transactionId); // transaction does not exsit
  error TAE(uint256 transactionId); // transaction already executed
  error TNC(uint256 transactionId, address voter); // transaction not confirmed
  error TAC(uint256 transactionId, address voter); // transaction is already confirmed

  event SubmitTransaction(
    address indexed proposor, uint256 indexed transactionId, address indexed to, uint256 value, bytes data
  );
  event ConfirmTransaction(address indexed voter, uint256 indexed transactionId);
  event RevokeConfirmation(address indexed voter, uint256 indexed transactionId);
  event ExecuteTransaction(address indexed voter, uint256 indexed transactionId);

  struct Transaction {
    address to;
    uint256 value;
    bytes data;
    bool executed;
    uint256 numConfirmations;
  }

  function submitTransaction(address to, uint256 value, bytes memory data) external;
  function confirmTransaction(uint256 transactionId) external;
  function revokeConfirmation(uint256 transactionId) external;
  function executeTransaction(uint256 transactionId) external;
}

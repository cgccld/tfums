// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";

abstract contract UniqueChecker {
  using BitMaps for BitMaps.BitMap;

  error AlreadyUsed();

  BitMaps.BitMap private _isUsed;

  function _setUsed(uint256 uid_) internal {
    if (_isUsed.get(uid_)) revert AlreadyUsed();
    _isUsed.set(uid_);
  }

  function _used(uint256 uid_) internal view returns (bool) {
    return _isUsed.get(uid_);
  }

  uint256[49] private __gap;
}

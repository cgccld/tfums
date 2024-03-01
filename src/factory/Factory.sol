// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IFactory} from "./IFactory.sol";
import {CREATE3} from "solmate/utils/CREATE3.sol";

contract Factory is IFactory {
  function getDeployed(address deployer_, bytes32 salt_) external view returns (address deployed) {
    deployed = CREATE3.getDeployed(keccak256(abi.encodePacked(deployer_, salt_)));
  }

  function deploy(bytes32 salt_, bytes calldata createBytecode_, uint256 value_) external {
    bytes32 salt;
    address sender;

    assembly {
      let ptr := mload(0x40)
      mstore(ptr, caller())
      mstore(add(ptr, 0x20), salt_)
      salt := keccak256(add(ptr, 0x0c), 0x34)
      sender := caller()
    }

    address deployed = CREATE3.deploy(salt, createBytecode_, value_);

    emit Contract_Deployed(sender, deployed);
  }
}

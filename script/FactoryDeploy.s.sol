// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Migrate.s.sol";
import "forge-std/Script.sol";
import {Factory} from "src/factory/Factory.sol";
import {Sample, SampleUUPS, SampleTransparent} from "src/Sample.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract FactoryDeploy is Script {
  bytes EMPTY_ARGS = "";

  function run() external {
    address factory = deployFactory();

    Factory(factory).deploy(0x0, vm.getCode("Sample.sol:Sample"), 0);

    Factory(factory).deploy(
      bytes32(uint256(0x1)), 
      abi.encodePacked(
        type(ERC1967Proxy).creationCode,
        abi.encode(
          deployCode("Sample.sol:SampleUUPS", EMPTY_ARGS),
          abi.encodeCall(
              SampleUUPS.initialize, ()
          )
        )
      ),
      0
    );

    Factory(factory).deploy(
      bytes32(uint256(0x2)), 
      abi.encodePacked(
        type(TransparentUpgradeableProxy).creationCode,
        abi.encode(
          deployCode("Sample.sol:SampleTransparent", EMPTY_ARGS),
          msg.sender,
          abi.encodeCall(
              SampleTransparent.initialize, ()
          )
        )
      ),
      0
    );
  }

  function deployFactory() public returns (address) {
    return deployCode("Factory.sol:Factory", abi.encode());
  }
}

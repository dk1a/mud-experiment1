// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld, System, ComponentDevSystem as _ComponentDevSystem } from "std-contracts/systems/ComponentDevSystem.sol";

uint256 constant ID = uint256(keccak256("system.ComponentDev"));

contract ComponentDevSystem is _ComponentDevSystem {
  constructor(IWorld _world, address _components) _ComponentDevSystem(_world, _components) {}
}
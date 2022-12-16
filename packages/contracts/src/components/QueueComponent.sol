// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { Uint256SetComponent } from "../utils/Uint256SetComponent.sol";

uint256 constant ID = uint256(keccak256("component.Queue"));

contract QueueComponent is Uint256SetComponent {
  constructor(address world) Uint256SetComponent(world, ID) {}
}

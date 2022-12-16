// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";

import { FromPrototype } from "@dk1a/solecslib/contracts/prototype/FromPrototype.sol";

import { ID } from "components/FromPrototypeComponent.sol";

using FromPrototype for FromPrototype.Self;

/// @dev namescopes arena participant entities so they can exist in multiple arenas
/// (for some entities like walls this is irrelevant)
function FromPrototype__Arena(
  IUint256Component components,
  uint256 arenaEntity
) view returns (FromPrototype.Self memory) {
  return FromPrototype.__construct(
    components,
    ID,
    abi.encode("Arena", arenaEntity)
  );
}

function newInstance__Arena(
  IUint256Component components,
  uint256 arenaEntity,
  uint256 protoEntity
) returns (uint256 entity) {
  return FromPrototype__Arena(components, arenaEntity)
    .newInstance(protoEntity);
}

function getPrototype__Arena(
  IUint256Component components,
  uint256 arenaEntity,
  uint256 entity
) view returns (uint256 protoEntity) {
  return FromPrototype__Arena(components, arenaEntity)
    .getPrototype(entity);
}

function getInstance__Arena(
  IUint256Component components,
  uint256 arenaEntity,
  uint256 protoEntity
) view returns (uint256 entity) {
  return FromPrototype__Arena(components, arenaEntity)
    .getInstance(protoEntity);
}
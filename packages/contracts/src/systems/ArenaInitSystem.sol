// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System, IWorld } from "solecs/System.sol";
import { addressToEntity, getAddressById } from "solecs/utils.sol";

import { ArenaStartTimeComponent, ID as ArenaStartTimeComponentID } from "components/ArenaStartTimeComponent.sol";
import { Coord } from "components/PositionComponent.sol";

import { LibArenaInit } from "libraries/LibArenaInit.sol";
import { LibArenaTemplate } from "libraries/LibArenaTemplate.sol";
import { LibRoster } from "libraries/LibRoster.sol";
import { LibQueue } from "libraries/LibQueue.sol";

import { newInstance__Arena } from "libraries/FromPrototype.sol";

uint256 constant ID = uint256(keccak256("system.ArenaInit"));

/// @title Queues callers for arena matches, initializes arenas when queue is filled
contract ArenaInitSystem is System {
  uint32 constant TARGET_CAPACITY = 4;
  uint32 constant GRID_SIZE = 3;

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory) public returns (bytes memory) {
    uint256 adminEntity = ID;
    uint256 protoEntityForQueue = addressToEntity(msg.sender);

    // (reverts on duplicate join)
    LibQueue.joinQueue(components, adminEntity, protoEntityForQueue);

    // TODO remove testing dummies
    for (uint256 i; i < 3; i++) {
      LibQueue.joinQueue(components, adminEntity, uint256(keccak256(abi.encode(msg.sender, i))));
    }

    if (!LibQueue.isFilled(components, adminEntity, TARGET_CAPACITY)) {
      // if queue isn't filled, wait for more to join
      return '';
    }
    // if filled, initialize a new arena

    (
      uint256 nonce,
      uint256[] memory gladiatorProtoEntities
    ) = LibQueue.removeBatch(components, adminEntity, TARGET_CAPACITY);
    assert(gladiatorProtoEntities.length == TARGET_CAPACITY);

    // make arenaEntity (nonce is in case 1 block makes several arenas)
    uint256 arenaEntity = uint256(keccak256(abi.encode("arenaEntity", block.timestamp, nonce)));

    ArenaStartTimeComponent arenaStartTimeComp = ArenaStartTimeComponent(getAddressById(components, ArenaStartTimeComponentID));
    arenaStartTimeComp.set(arenaEntity, block.timestamp);

    (
      Coord[] memory gladiatorPositions,
      Coord[] memory wallPositions
    ) = LibArenaTemplate.makeSquareCapacity4(gladiatorProtoEntities, 3);

    // gladiators
    for (uint256 i; i < gladiatorProtoEntities.length; i++) {
      uint256 gladiatorProtoEntity = gladiatorProtoEntities[i];
      uint256 gladiatorEntity = newInstance__Arena(components, arenaEntity, gladiatorProtoEntity);

      // register in this arena's roster
      LibRoster.register(
        components,
        arenaEntity,
        gladiatorEntity
      );

      // initialize participant
      LibArenaInit.initGladiator(
        components,
        arenaEntity,
        gladiatorEntity,
        gladiatorPositions[i]
      );
    }

    // walls
    for (uint256 i; i < wallPositions.length; i++) {
      LibArenaInit.initWall(
        components,
        arenaEntity,
        i,
        wallPositions[i]
      );
    }

    return '';
  }

  function executeTyped() public returns (bytes memory) {
    return execute(abi.encode());
  }
}

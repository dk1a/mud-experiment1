// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System, IWorld } from "solecs/System.sol";
import { addressToEntity } from "solecs/utils.sol";

import { Coord } from "components/PositionComponent.sol";

import { newInstance__Arena } from "libraries/FromPrototype.sol";

import { LibConfig } from "libraries/LibConfig.sol";
import { LibEnergy } from "libraries/LibEnergy.sol";
import { LibPosition } from "libraries/LibPosition.sol";
import { LibAttack } from "libraries/LibAttack.sol";
import { LibCleanup } from "libraries/LibCleanup.sol";

uint256 constant ID = uint256(keccak256("system.Movement"));

contract MovementSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (
      uint256 arenaEntity,
      Coord memory posDiff
    ) = abi.decode(args, (uint256, Coord));

    uint256 protoEntity = addressToEntity(msg.sender);
    uint256 entity = newInstance__Arena(components, arenaEntity, protoEntity);

    // posDiff is a relative move, convert it to absolute coordiantes
    Coord memory toPosition = LibPosition.getPosition(components, entity);
    toPosition.x += posDiff.x;
    toPosition.y += posDiff.y;

    // if not occupied, move there
    if (!LibPosition.isOccupied(components, arenaEntity, toPosition)) {
      // subtract energy cost (reverts if unable to)
      LibEnergy.useEnergy(
        components,
        arenaEntity,
        entity,
        LibConfig.moveEnergyCost()
      );

      // move to new position (reverts if unable to)
      LibPosition.moveTo(components, entity, toPosition, LibConfig.moveDistance());

    // if occupied, try to attack!
    } else if (LibAttack.withAttackableTarget(components, arenaEntity, toPosition)) {
      // subtract energy cost (reverts if unable to)
      LibEnergy.useEnergy(
        components,
        arenaEntity,
        entity,
        LibConfig.strikeEnergyCost()
      );

      // attack whatever is there
      LibAttack.strikeAtPosition(components, arenaEntity, entity, toPosition);

    // if can't move and there's nothing to attack, do nothing
    } else {
      return '';
    }

    // cleanup (removes killed entities, declares winner if match is over)
    LibCleanup.cleanup(components, arenaEntity);

    return '';
  }

  function executeTyped(
    uint256 arenaEntity,
    Coord memory posDiff
  ) public returns (bytes memory) {
    return execute(abi.encode(arenaEntity, posDiff));
  }
}

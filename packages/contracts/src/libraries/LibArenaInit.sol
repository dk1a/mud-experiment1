// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { PositionComponent, ID as PositionComponentID, LayeredCoord, Coord } from "components/PositionComponent.sol";
import { HealthComponent, ID as HealthComponentID } from "components/HealthComponent.sol";
import { EnergyComponent, ID as EnergyComponentID } from "components/EnergyComponent.sol";
import { EnergySpentComponent, ID as EnergySpentComponentID } from "components/EnergySpentComponent.sol";
import { ArmorComponent, ID as ArmorComponentID } from "components/ArmorComponent.sol";
import { DamageComponent, ID as DamageComponentID } from "components/DamageComponent.sol";

import { LibConfig } from "libraries/LibConfig.sol";

library LibArenaInit {
  error LibArenaInit__PositionOverlapNotAllowed();

  function initGladiator(
    IUint256Component components,
    uint256 arenaEntity,
    uint256 gladiatorEntity,
    Coord memory position
  ) internal {
    initPosition(components, arenaEntity, gladiatorEntity, position);
    initStats(
      components,
      gladiatorEntity,
      LibConfig.gladiatorInitHealth(),
      LibConfig.gladiatorInitEnergy(),
      LibConfig.gladiatorInitArmor(),
      LibConfig.gladiatorInitDamage()
    );
  }

  function initWall(
    IUint256Component components,
    uint256 arenaEntity,
    uint256 wallIndex,
    Coord memory position
  ) internal {
    uint256 wallEntity = uint256(keccak256(abi.encode("wallEntity", block.timestamp, arenaEntity, wallIndex)));
    initPosition(components, arenaEntity, wallEntity, position);
  }

  function initPosition(
    IUint256Component components,
    uint256 arenaEntity,
    uint256 entity,
    Coord memory position
  ) internal {
    PositionComponent positionComp = PositionComponent(getAddressById(components, PositionComponentID));

    LayeredCoord memory layeredPosition = LayeredCoord(position.x, position.y, arenaEntity);

    // check if the position is occupied
    // TODO position check should be improved if spawning can happen
    // in the middle of an ongoing match.
    // (or you could allow overlap, it'd just really complicate things, especially UX)
    uint256[] memory overlapEntities = positionComp.getEntitiesWithValue(layeredPosition);
    if (overlapEntities.length > 0) {
      revert LibArenaInit__PositionOverlapNotAllowed();
    }

    // place inside the arena
    positionComp.set(entity, layeredPosition);
  }

  function initStats(
    IUint256Component components,
    uint256 entity,
    uint32 initHealth,
    uint32 initEnergy,
    uint32 initArmor,
    uint32 initDamage
  ) internal {
    HealthComponent healthComp = HealthComponent(getAddressById(components, HealthComponentID));
    EnergyComponent energyComp = EnergyComponent(getAddressById(components, EnergyComponentID));
    EnergySpentComponent energySpentComp = EnergySpentComponent(getAddressById(components, EnergySpentComponentID));
    ArmorComponent armorComp = ArmorComponent(getAddressById(components, ArmorComponentID));
    DamageComponent damageComp = DamageComponent(getAddressById(components, DamageComponentID));

    // initialize
    healthComp.set(entity, initHealth);
    energyComp.set(entity, initEnergy);
    energySpentComp.set(entity, 0);
    armorComp.set(entity, initArmor);
    damageComp.set(entity, initDamage);
  }

  function removeEntity(
    IUint256Component components,
    uint256 entity
  ) internal {
    PositionComponent positionComp = PositionComponent(getAddressById(components, PositionComponentID));
    HealthComponent healthComp = HealthComponent(getAddressById(components, HealthComponentID));
    EnergyComponent energyComp = EnergyComponent(getAddressById(components, EnergyComponentID));
    EnergySpentComponent energySpentComp = EnergySpentComponent(getAddressById(components, EnergySpentComponentID));
    ArmorComponent armorComp = ArmorComponent(getAddressById(components, ArmorComponentID));
    DamageComponent damageComp = DamageComponent(getAddressById(components, DamageComponentID));

    positionComp.remove(entity);
    healthComp.remove(entity);
    energyComp.remove(entity);
    energySpentComp.remove(entity);
    armorComp.remove(entity);
    damageComp.remove(entity);
  }
}

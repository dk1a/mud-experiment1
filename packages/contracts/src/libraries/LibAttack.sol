// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { Coord } from "components/PositionComponent.sol";
import { HealthComponent, ID as HealthComponentID } from "components/HealthComponent.sol";
import { ArmorComponent, ID as ArmorComponentID } from "components/ArmorComponent.sol";
import { DamageComponent, ID as DamageComponentID } from "components/DamageComponent.sol";

import { LibPosition } from "libraries/LibPosition.sol";

library LibAttack {
  error LibAttack__OutOfRange();

  // whether the position has something to attack
  function withAttackableTarget(
    IUint256Component components,
    uint256 arenaEntity,
    Coord memory defenderPosition
  ) internal view returns (bool) {
    HealthComponent healthComp = HealthComponent(getAddressById(components, HealthComponentID));
    uint256[] memory defenderEntities = LibPosition.getEntitiesAtPosition(components, arenaEntity, defenderPosition);
    for (uint256 i; i < defenderEntities.length; i++) {
      if (healthComp.has(defenderEntities[i])) {
        return true;
      }
    }
    return false;
  }

  function strikeAtPosition(
    IUint256Component components,
    uint256 arenaEntity,
    uint256 attackerEntity,
    Coord memory defenderPosition
  ) internal {
    // attack everything in given position
    uint256[] memory defenderEntities = LibPosition.getEntitiesAtPosition(components, arenaEntity, defenderPosition);
    // this can lead to attacking nothing, if the position is empty
    for (uint256 i; i < defenderEntities.length; i++) {
      genericAttack(
        components,
        attackerEntity,
        defenderEntities[i],
        1
      );
    }
  }

  function throwAtEntity(
    IUint256Component components,
    uint256 attackerEntity,
    uint256 defenderEntity
  ) internal {
    genericAttack(
      components,
      attackerEntity,
      defenderEntity,
      4
    );
  }

  function genericAttack(
    IUint256Component components,
    uint256 attackerEntity,
    uint256 defenderEntity,
    int32 maxDistance
  ) internal {
    int32 distance = LibPosition.getDistance(components, attackerEntity, defenderEntity);
    if (distance > maxDistance) {
      revert LibAttack__OutOfRange();
    }

    HealthComponent healthComp = HealthComponent(getAddressById(components, HealthComponentID));
    ArmorComponent armorComp = ArmorComponent(getAddressById(components, ArmorComponentID));
    DamageComponent damageComp = DamageComponent(getAddressById(components, DamageComponentID));

    uint32 defenderHealth = healthComp.getValue(defenderEntity);
    uint32 defenderArmor = 0;
    if (armorComp.has(defenderEntity)) {
      defenderArmor = armorComp.getValue(defenderEntity);
    }

    uint32 attackerDamage = damageComp.getValue(attackerEntity);

    // deal damage
    if (attackerDamage > defenderArmor) {
      uint32 adjustedDamage = attackerDamage - defenderArmor;
      healthComp.set(
        defenderEntity,
        adjustedDamage > defenderHealth ? 0 : defenderHealth - adjustedDamage
      );
    }
  }
}

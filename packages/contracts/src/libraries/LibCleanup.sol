// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { HealthComponent, ID as HealthComponentID } from "components/HealthComponent.sol";
import { WinCountComponent, ID as WinCountComponentID } from "components/WinCountComponent.sol";

import { getPrototype__Arena } from "libraries/FromPrototype.sol";
import { LibArenaInit } from "libraries/LibArenaInit.sol";
import { LibRoster } from "libraries/LibRoster.sol";

library LibCleanup {
  function cleanup(
    IUint256Component components,
    uint256 arenaEntity
  ) internal {
    uint256[] memory entities = LibRoster.getEntities(components, arenaEntity);

    HealthComponent healthComp = HealthComponent(getAddressById(components, HealthComponentID));

    for (uint256 i; i < entities.length; i++) {
      uint256 entity = entities[i];
      // remove killed entities
      if (healthComp.has(entity) && healthComp.getValue(entity) == 0) {
        LibArenaInit.removeEntity(components, entity);
        LibRoster.removeEntity(components, entity);
      }
    }

    // if there's a winner
    entities = LibRoster.getEntities(components, arenaEntity);
    if (entities.length == 1) {
      uint256 entity = entities[0];
      uint256 protoEntity = getPrototype__Arena(components, arenaEntity, entity);

      // increment winCount
      WinCountComponent winCountComp = WinCountComponent(getAddressById(components, WinCountComponentID));
      uint32 winCount;
      if (winCountComp.has(protoEntity)) {
        winCount = winCountComp.getValue(protoEntity);
      }
      winCountComp.set(protoEntity, winCount + 1);

      // remove the last entity
      LibArenaInit.removeEntity(components, entity);
      LibRoster.removeEntity(components, entity);
    }
  }
}

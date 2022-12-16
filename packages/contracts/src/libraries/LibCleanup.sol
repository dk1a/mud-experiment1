// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { HealthComponent, ID as HealthComponentID } from "components/HealthComponent.sol";
import { WinCountComponent, ID as WinCountComponentID } from "components/WinCountComponent.sol";

import { getInstance__Arena } from "libraries/FromPrototype.sol";
import { LibArenaInit } from "libraries/LibArenaInit.sol";
import { LibRoster } from "libraries/LibRoster.sol";

library LibCleanup {
  function cleanup(
    IUint256Component components,
    uint256 arenaEntity
  ) internal {
    uint256[] memory protoEntities = LibRoster.getValue(components, arenaEntity);

    HealthComponent healthComp = HealthComponent(getAddressById(components, HealthComponentID));

    for (uint256 i; i < protoEntities.length; i++) {
      uint256 protoEntity = protoEntities[i];
      uint256 entity = getInstance__Arena(components, arenaEntity, protoEntity);
      // remove killed entities
      if (healthComp.has(entity) && healthComp.getValue(entity) == 0) {
        LibArenaInit.removeEntity(components, entity);
        LibRoster.removeProtoEntity(components, arenaEntity, protoEntity);
      }
    }

    // if there's a winner
    uint256 rosterSize = LibRoster.getSize(components, arenaEntity);
    if (rosterSize == 1) {
      uint256 protoEntity = LibRoster.getValue(components, arenaEntity)[0];

      // increment winCount
      WinCountComponent winCountComp = WinCountComponent(getAddressById(components, WinCountComponentID));
      uint256 winCount;
      if (winCountComp.has(protoEntity)) {
        winCount = winCountComp.getValue(protoEntity);
      }
      winCountComp.set(protoEntity, winCount + 1);

      // remove the last entity
      uint256 entity = getInstance__Arena(components, arenaEntity, protoEntity);
      LibArenaInit.removeEntity(components, entity);
      LibRoster.removeProtoEntity(components, arenaEntity, protoEntity);
    }
  }
}

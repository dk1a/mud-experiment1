// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { RosterComponent, ID as RosterComponentID } from "components/RosterComponent.sol";

library LibRoster {
  error LibRoster__AlreadyRegistered();
  error LibRoster__NotRegistered();

  function _comp(IUint256Component components) internal view returns (RosterComponent) {
    return RosterComponent(getAddressById(components, RosterComponentID));
  }

  function getEntities(
    IUint256Component components,
    uint256 arenaEntity
  ) internal view returns (uint256[] memory) {
    return _comp(components).getEntitiesWithValue(arenaEntity);
  }

  function register(
    IUint256Component components,
    uint256 arenaEntity,
    uint256 entity
  ) internal {
    RosterComponent rosterComp = _comp(components);

    if (rosterComp.has(entity)) {
      revert LibRoster__AlreadyRegistered();
    }
    rosterComp.set(entity, arenaEntity);
  }

  function requireRegistered(
    IUint256Component components,
    uint256 entity
  ) internal view {
    if (!_comp(components).has(entity)) {
      revert LibRoster__NotRegistered();
    }
  }

  function removeEntity(
    IUint256Component components,
    uint256 entity
  ) internal {
    _comp(components).remove(entity);
  }
}

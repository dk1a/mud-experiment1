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

  function getSize(
    IUint256Component components,
    uint256 arenaEntity
  ) internal view returns (uint256) {
    return _comp(components).itemSetSize(arenaEntity);
  }

  function getValue(
    IUint256Component components,
    uint256 arenaEntity
  ) internal view returns (uint256[] memory) {
    return _comp(components).getValue(arenaEntity);
  }

  function register(
    IUint256Component components,
    uint256 arenaEntity,
    uint256 protoEntity
  ) internal {
    RosterComponent rosterComp = _comp(components);

    if (rosterComp.hasItem(arenaEntity, protoEntity)) {
      revert LibRoster__AlreadyRegistered();
    }
    rosterComp.addItem(arenaEntity, protoEntity);
  }

  function requireRegistered(
    IUint256Component components,
    uint256 arenaEntity,
    uint256 protoEntity
  ) internal view {
    if (!_comp(components).hasItem(arenaEntity, protoEntity)) {
      revert LibRoster__NotRegistered();
    }
  }

  function removeProtoEntity(
    IUint256Component components,
    uint256 arenaEntity,
    uint256 protoEntity
  ) internal {
    _comp(components).removeItem(arenaEntity, protoEntity);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { ArenaStartTimeComponent, ID as ArenaStartTimeComponentID } from "components/ArenaStartTimeComponent.sol";
import { EnergyComponent, ID as EnergyComponentID } from "components/EnergyComponent.sol";
import { EnergySpentComponent, ID as EnergySpentComponentID } from "components/EnergySpentComponent.sol";

library LibEnergy {
  error LibEnergy__ArenaNotInitialized();
  error LibEnergy__AmountNotYetSpendable();
  error LibEnergy__AmountNotAvailable();

  uint32 constant ALLOW_ENERGY_AMOUNT = 1000;
  uint32 constant ALLOW_ENERGY_INTERVAL = 8;

  function useEnergy(
    IUint256Component components,
    uint256 arenaEntity,
    uint256 entity,
    uint32 energyAmount
  ) internal {
    EnergyComponent energyComp = EnergyComponent(getAddressById(components, EnergyComponentID));
    EnergySpentComponent energySpentComp = EnergySpentComponent(getAddressById(components, EnergySpentComponentID));

    uint32 energyAvailable = energyComp.getValue(entity);
    if (energyAmount > energyAvailable) {
      revert LibEnergy__AmountNotAvailable();
    }

    uint32 energySpendable = _energySpendableNow(components, arenaEntity);
    uint32 energySpent = energySpentComp.getValue(entity);
    if (energyAmount > energySpendable - energySpent) {
      revert LibEnergy__AmountNotYetSpendable();
    }

    energyComp.set(entity, energyAvailable - energyAmount);
    energySpentComp.set(entity, energySpent + energyAmount);
  }

  function _energySpendableNow(
    IUint256Component components,
    uint256 arenaEntity
  ) internal view returns (uint32) {
    // get arena start time
    ArenaStartTimeComponent arenaStartTimeComp = ArenaStartTimeComponent(getAddressById(components, ArenaStartTimeComponentID));
    if (!arenaStartTimeComp.has(arenaEntity)) revert LibEnergy__ArenaNotInitialized();
    uint256 arenaStartTime = arenaStartTimeComp.getValue(arenaEntity);
    if (arenaStartTime == 0) revert LibEnergy__ArenaNotInitialized();

    // spendable energy is increased by `ALLOW_ENERGY_AMOUNT` every `ALLOW_ENERGY_INTERVAL` seconds
    uint256 intervals = (block.timestamp - arenaStartTime) / ALLOW_ENERGY_INTERVAL;
    if (intervals >= type(uint32).max / ALLOW_ENERGY_AMOUNT) return type(uint32).max;
    return uint32(intervals) * ALLOW_ENERGY_AMOUNT;
  }
}

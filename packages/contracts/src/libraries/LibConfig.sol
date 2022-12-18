// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

/// @dev TODO config should probably be done via components (by arena admins?), not hardcoded
library LibConfig {
  function moveDistance() internal pure returns (int32) {
    return 1;
  }

  function moveEnergyCost() internal pure returns (uint32) {
    return 50;
  }

  function strikeEnergyCost() internal pure returns (uint32) {
    return 100;
  }

  function throwEnergyCost() internal pure returns (uint32) {
    return 250;
  }

  function upgradeArmorEnergyCost() internal pure returns (uint32) {
    return 600;
  }

  function upgradeDamageEnergyCost() internal pure returns (uint32) {
    return 750;
  }

  function gladiatorInitHealth() internal pure returns (uint32) {
    return 100;
  }

  function gladiatorInitEnergy() internal pure returns (uint32) {
    return 10_000;
  }

  function gladiatorInitArmor() internal pure returns (uint32) {
    return 5;
  }

  function gladiatorInitDamage() internal pure returns (uint32) {
    return 10;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

/// @dev TODO config should probably be done via components (by arena admins?), not hardcoded
library LibConfig {
  function moveDistance() internal pure returns (int32) {
    return 1;
  }

  function moveEnergyCost() internal pure returns (uint256) {
    return 50;
  }

  function strikeEnergyCost() internal pure returns (uint256) {
    return 100;
  }

  function throwEnergyCost() internal pure returns (uint256) {
    return 250;
  }

  function gladiatorInitHealth() internal pure returns (uint256) {
    return 100;
  }

  function gladiatorInitEnergy() internal pure returns (uint256) {
    return 10_000;
  }

  function gladiatorInitArmor() internal pure returns (uint256) {
    return 5;
  }

  function gladiatorInitDamage() internal pure returns (uint256) {
    return 10;
  }
}

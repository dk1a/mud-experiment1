// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System, IWorld } from "solecs/System.sol";
import { addressToEntity, getAddressById } from "solecs/utils.sol";

import { Uint32BareComponent } from "std-contracts/components/Uint32BareComponent.sol";
import { ArmorComponent, ID as ArmorComponentID } from "components/ArmorComponent.sol";
import { DamageComponent, ID as DamageComponentID } from "components/DamageComponent.sol";

import { newInstance__Arena } from "libraries/FromPrototype.sol";

import { LibConfig } from "libraries/LibConfig.sol";
import { LibEnergy } from "libraries/LibEnergy.sol";
import { LibPosition } from "libraries/LibPosition.sol";
import { LibAttack } from "libraries/LibAttack.sol";
import { LibCleanup } from "libraries/LibCleanup.sol";

uint256 constant ID = uint256(keccak256("system.Upgrade"));

contract UpgradeSystem is System {
  error UpgradeSystem__UnknownUpgradeType();

  enum UpgradeType {
    ARMOR,
    DAMAGE
  }

  uint32 constant UPGRADE_INCREMENT = 5;

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (
      uint256 arenaEntity,
      UpgradeType upgradeType
    ) = abi.decode(args, (uint256, UpgradeType));

    uint256 protoEntity = addressToEntity(msg.sender);
    uint256 entity = newInstance__Arena(components, arenaEntity, protoEntity);

    Uint32BareComponent comp;
    uint32 energyCost;
    if (upgradeType == UpgradeType.ARMOR) {
      energyCost = LibConfig.upgradeArmorEnergyCost();
      comp = Uint32BareComponent(getAddressById(components, ArmorComponentID));
    } else if (upgradeType == UpgradeType.DAMAGE) {
      energyCost = LibConfig.upgradeDamageEnergyCost();
      comp = Uint32BareComponent(getAddressById(components, DamageComponentID));
    } else {
      revert UpgradeSystem__UnknownUpgradeType();
    }

    // subtract energy cost (reverts if unable to)
    LibEnergy.useEnergy(
      components,
      arenaEntity,
      entity,
      energyCost
    );

    // upgrade
    uint32 value = comp.getValue(entity);
    comp.set(entity, value + UPGRADE_INCREMENT);

    return '';
  }

  function executeTyped(
    uint256 arenaEntity,
    UpgradeType upgradeType
  ) public {
    execute(abi.encode(arenaEntity, upgradeType));
  }

  function upgradeArmor(uint256 arenaEntity) public {
    executeTyped(arenaEntity, UpgradeType.ARMOR);
  }

  function upgradeDamage(uint256 arenaEntity) public {
    executeTyped(arenaEntity, UpgradeType.DAMAGE);
  }
}

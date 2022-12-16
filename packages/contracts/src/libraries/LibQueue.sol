// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";
import { LibUtils } from "std-contracts/libraries/LibUtils.sol";

import { QueueComponent, ID as QueueComponentID } from "components/QueueComponent.sol";
import { QueueNonceComponent, ID as QueueNonceComponentID } from "components/QueueNonceComponent.sol";

library LibQueue {
  error LibQueue__AlreadyQueued();
  error LibQueue__QueueSizeTooSmall();

  function _queueComp(IUint256Component components) internal view returns (QueueComponent) {
    return QueueComponent(getAddressById(components, QueueComponentID));
  }

  function joinQueue(
    IUint256Component components,
    uint256 adminEntity,
    uint256 protoEntity
  ) internal {
    QueueComponent queueComp = _queueComp(components);
    if (queueComp.hasItem(adminEntity, protoEntity)) {
      revert LibQueue__AlreadyQueued();
    }
    queueComp.addItem(adminEntity, protoEntity);
  }

  function isFilled(
    IUint256Component components,
    uint256 adminEntity,
    uint256 targetCapacity
  ) internal view returns (bool) {
    return targetCapacity <= _queueComp(components).itemSetSize(adminEntity);
  }

  /**
   * @dev Extract `batchSize` number of protoEntities from the queue; also provides a unique nonce
   */
  function removeBatch(
    IUint256Component components,
    uint256 adminEntity,
    uint256 batchSize
  ) internal returns (uint256 nonce, uint256[] memory protoEntities) {
    if (!isFilled(components, adminEntity, batchSize)) {
      revert LibQueue__QueueSizeTooSmall();
    }

    QueueComponent queueComp = _queueComp(components);
    uint256[] memory allEntities = queueComp.getValue(adminEntity);

    // remove `batchSize` protoEntities from the queue
    protoEntities = new uint256[](batchSize);
    for (uint256 i; i < batchSize; i++) {
      protoEntities[i] = allEntities[i];
      queueComp.removeItem(adminEntity, allEntities[i]);
    }

    // get and increment nonce
    // TODO nonce isn't really related to queues. But also queues are a poorly implemented in general
    QueueNonceComponent queueNonceComp = QueueNonceComponent(getAddressById(components, QueueNonceComponentID));
    nonce = 0;
    if (queueNonceComp.has(adminEntity)) {
      nonce = queueNonceComp.getValue(adminEntity);
    }
    queueNonceComp.set(adminEntity, nonce + 1);

    return (nonce, protoEntities);
  }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";
import { LibUtils } from "std-contracts/libraries/LibUtils.sol";

import { PositionComponent, ID as PositionComponentID, LayeredCoord, Coord } from "components/PositionComponent.sol";

library LibPosition {
  error LibPosition__OverlapNotAllowed();
  error LibPosition__DistanceNotAllowed();

  function _comp(IUint256Component components) internal view returns (PositionComponent) {
    return PositionComponent(getAddressById(components, PositionComponentID));
  }

  function getPosition(
    IUint256Component components,
    uint256 entity
  ) internal view returns (Coord memory) {
    return _removeLayer(_comp(components).getValue(entity));
  }

  function isOccupied(
    IUint256Component components,
    uint256 layer,
    Coord memory position
  ) internal view returns (bool) {
    return getEntitiesAtPosition(components, layer, position).length > 0;
  }

  function getEntitiesAtPosition(
    IUint256Component components,
    uint256 layer,
    Coord memory position
  ) internal view returns (uint256[] memory) {
    return _comp(components).getEntitiesWithValue(_addLayer(position, layer));
  }

  function requireNotOccupied(
    IUint256Component components,
    uint256 layer,
    Coord memory position
  ) internal view {
    if (isOccupied(components, layer, position)) {
      revert LibPosition__OverlapNotAllowed();
    }
  }

  function moveTo(
    IUint256Component components,
    uint256 entity,
    Coord memory _toPosition,
    int32 allowedDistance
  ) internal {
    LayeredCoord memory fromPosition = _comp(components).getValue(entity);
    LayeredCoord memory toPosition = LayeredCoord(_toPosition.x, _toPosition.y, fromPosition.layer);

    requireNotOccupied(components, fromPosition.layer, _toPosition);

    _requireAllowedDistance(fromPosition, toPosition, allowedDistance);

    _comp(components).set(entity, toPosition);
  }

  function getDistance(
    IUint256Component components,
    uint256 fromEntity,
    uint256 toEntity
  ) internal view returns (int32) {
    return LibUtils.manhattan(
      getPosition(components, fromEntity),
      getPosition(components, toEntity)
    );
  }

  function _requireAllowedDistance(
    LayeredCoord memory fromPosition,
    LayeredCoord memory toPosition,
    int32 allowedDistance
  ) internal pure {
    int32 distance = LibUtils.manhattan(_removeLayer(fromPosition), _removeLayer(toPosition));
    if (distance > allowedDistance) {
      revert LibPosition__DistanceNotAllowed();
    }
  }

  function _addLayer(
    Coord memory coord,
    uint256 layer
  ) internal pure returns (LayeredCoord memory) {
    return LayeredCoord(coord.x, coord.y, layer);
  }

  function _removeLayer(
    LayeredCoord memory coord
  ) internal pure returns (Coord memory) {
    return Coord(coord.x, coord.y);
  }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { Coord } from "components/PositionComponent.sol";

/// @title Arena layout templates
library LibArenaTemplate {
  error LibArenaTemplate__InvalidGridSize();
  error LibArenaTemplate__InvalidCapacity();

  /// @dev very hardcoded and simple square for 4 players, 1 in each corner
  function makeSquareCapacity4(
    uint256[] memory gladiatorProtoEntities,
    uint32 gridSize
  ) internal pure returns (
    Coord[] memory gladiatorPositions,
    Coord[] memory wallPositions
  ) {
    if (gridSize < 2) revert LibArenaTemplate__InvalidGridSize();
    if (gridSize > uint32(type(int32).max)) revert LibArenaTemplate__InvalidGridSize();

    if (gladiatorProtoEntities.length != 4) revert LibArenaTemplate__InvalidCapacity();

    int32 gridLastIndex = int32(gridSize) - 1;
    // TODO make less hardcoded?
    gladiatorPositions = new Coord[](4);
    gladiatorPositions[0] = Coord(0, 0);
    gladiatorPositions[1] = Coord(0, gridLastIndex);
    gladiatorPositions[2] = Coord(gridLastIndex, 0);
    gladiatorPositions[3] = Coord(gridLastIndex, gridLastIndex);

    // walls
    uint256 wallIndex;
    wallPositions = new Coord[](gridSize * 4 + 4);
    for (int32 i = -1; i <= gridLastIndex + 1; i++) {
      // bottom row
      wallPositions[wallIndex++] = Coord(-1, i);
      // top row
      wallPositions[wallIndex++] = Coord(gridLastIndex + 1, i);
      // exclude top and bottom cells since the rows already filled those
      if (i != -1 && i != gridLastIndex + 1) {
        // left column
        wallPositions[wallIndex++] = Coord(i, -1);
        // right column
        wallPositions[wallIndex++] = Coord(i, gridLastIndex + 1);
      }
    }
  }
}

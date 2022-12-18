import { formatEntityID } from "@latticexyz/network";
import { id } from "ethers/lib/utils";

export const adminEntityId = formatEntityID(id("system.ArenaInit"))

export enum Direction {
  Top,
  Right,
  Bottom,
  Left,
}

export const Directions = {
  [Direction.Top]: { x: 0, y: -1 },
  [Direction.Right]: { x: 1, y: 0 },
  [Direction.Bottom]: { x: 0, y: 1 },
  [Direction.Left]: { x: -1, y: 0 },
};

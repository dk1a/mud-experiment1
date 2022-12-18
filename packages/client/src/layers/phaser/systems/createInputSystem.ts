import { getComponentValue } from "@latticexyz/recs";
import { Coord } from "@latticexyz/utils";
import { throttleTime } from "rxjs";
import { Direction, Directions } from "../../../constants";
import { NetworkLayer } from "../../network";
import { PhaserLayer } from "../types";

export function createInputSystem(network: NetworkLayer, phaser: PhaserLayer) {
  const {
    world,
    scenes: {
      Main: {
        input,
      },
    },
  } = phaser;

  const keySub = input.keyboard$.pipe(throttleTime(500)).subscribe((key) => {
    let posDiff: Coord;

    if (key.keyCode === Phaser.Input.Keyboard.KeyCodes.UP) {
      posDiff = Directions[Direction.Top];
    } else if (key.keyCode === Phaser.Input.Keyboard.KeyCodes.RIGHT) {
      posDiff = Directions[Direction.Right];
    } else if (key.keyCode === Phaser.Input.Keyboard.KeyCodes.DOWN) {
      posDiff = Directions[Direction.Bottom];
    } else if (key.keyCode === Phaser.Input.Keyboard.KeyCodes.LEFT) {
      posDiff = Directions[Direction.Left];
    } else {
      return;
    }

    // move will fail if position isn't initialized, no need to call it in that case
    let position = getComponentValue(network.components.Position, network.api.getPlayerEntity());
    if (!position) return console.warn("position not initialized");

    network.api.move(posDiff);
  });

  world.registerDisposer(() => keySub?.unsubscribe());
}
import { createWorld } from "@latticexyz/recs";
import { config } from "./config";
import { createPhaserEngine } from "@latticexyz/phaserx";

export async function setupPhaser() {
  const world = createWorld();

  const { game, scenes, dispose: disposePhaser } = await createPhaserEngine(config);
  world.registerDisposer(disposePhaser);

  const context = {
    world,
    game,
    scenes,
  };

  return context;
}

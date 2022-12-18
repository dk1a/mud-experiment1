import { namespaceWorld } from "@latticexyz/recs";
import { createPhaserEngine } from "@latticexyz/phaserx";
import { phaserConfig } from "./config";
import { NetworkLayer } from "../network";
import { createInputSystem } from "./systems/createInputSystem";
import { createPositionSystem } from "./systems/createPositionSystem";
import { createHealthBarSystem } from "./systems/createHealthBarSystem";

/**
 * The Phaser layer is responsible for rendering game objects to the screen.
 */
export async function createPhaserLayer(network: NetworkLayer) {
  // --- WORLD ----------------------------------------------------------------------
  const world = namespaceWorld(network.world, "phaser");

  // --- COMPONENTS -----------------------------------------------------------------
  const components = {};

  // --- PHASER ENGINE SETUP --------------------------------------------------------
  const { game, scenes, dispose: disposePhaser } = await createPhaserEngine(phaserConfig);
  world.registerDisposer(disposePhaser);

  scenes.Main.camera.centerOn(0, 0)

  // --- LAYER CONTEXT --------------------------------------------------------------
  const context = {
    world,
    components,
    network,
    game,
    scenes,
  };

  // --- SYSTEMS --------------------------------------------------------------------
  createInputSystem(network, context)
  createPositionSystem(network, context)
  createHealthBarSystem(network, context)

  return context;
}

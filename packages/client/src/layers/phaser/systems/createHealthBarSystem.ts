import { tileCoordToPixelCoord } from "@latticexyz/phaserx";
import { defineExitSystem, defineSystem, getComponentValue, Has } from "@latticexyz/recs";
import { NetworkLayer } from "../../network";
import { TILE_WIDTH } from "../constants";
import { PhaserLayer } from "../types";

export function createHealthBarSystem(network: NetworkLayer, phaser: PhaserLayer) {
  const {
    world,
    components: { Position, Health },
    api: { getArenaEntity }
  } = network;

  const {
    scenes: {
      Main: {
        objectPool,
        config,
        maps: {
          Main: { tileWidth, tileHeight },
        },
      },
    },
  } = phaser;

  // show objects with position
  defineSystem(world, [Has(Position), Has(Health)], (update) => {
    const position = getComponentValue(Position, update.entity);
    if (!position) return;

    // only display positions for the selected arena
    const arenaEntity = getArenaEntity();
    if (position?.layer !== arenaEntity) return;

    const { x, y } = tileCoordToPixelCoord(position, tileWidth, tileHeight);

    // TODO this doesn't seem like the best way to make attached entities
    const healthBar = objectPool.get(update.entity + 'healthBar', "Rectangle")

    healthBar.setComponent({
      id: Position.id,
      once: (gameObject) => {
        gameObject.setFillStyle(0x00ff00);
        gameObject.setPosition(x + 2, y + 1);
      },
    });

    healthBar.setComponent({
      id: Health.id,
      once: (gameObject) => {
        // TODO you should have smth like a config component instead of hardcode
        const maxHealth = 100;

        const health = getComponentValue(Health, update.entity)?.value ?? 0;
        let widthScale = health / maxHealth;
        if (widthScale < 0) widthScale = 0;
        gameObject.setSize((TILE_WIDTH - 2) * widthScale, 1);
      }
    })
  });

  // hide objects that lost their position
  defineExitSystem(world, [Has(Position)], (update) => {
    const position = update.value[0];
    const prevPosition = update.value[1];

    if (position) return;

    // only remove for the selected arena
    const arenaEntity = getArenaEntity();
    if (prevPosition?.layer !== arenaEntity) return;

    // remove destroyed objects
    const object = objectPool.get(update.entity + 'healthBar', "Existing")
    if (object) {
      object.removeComponent(Position.id, true);
      object.despawn();
    }
  });
}
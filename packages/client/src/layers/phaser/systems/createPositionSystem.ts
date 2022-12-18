import { tileCoordToPixelCoord } from "@latticexyz/phaserx";
import { defineComponentSystem, defineRxSystem, defineSystem, EntityID, EntityIndex, getComponentValue, Has, hasComponent } from "@latticexyz/recs";
import { combineLatest } from "rxjs";
import { NetworkLayer } from "../../network";
import { Sprites, TILE_WIDTH } from "../constants";
import { PhaserLayer } from "../types";

export function createPositionSystem(network: NetworkLayer, phaser: PhaserLayer) {
  const {
    world,
    components: { Position, Health },
    api: { getArenaEntity, getPlayerEntity }
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
  defineRxSystem(world, combineLatest([Position.update$, Health.update$]), ([update,]) => {
    const entity = update.entity as EntityIndex
    const position = getComponentValue(Position, entity);
    if (!position) return;

    // only display positions for the selected arena
    const arenaEntity = getArenaEntity();
    if (position?.layer !== arenaEntity) return;

    const { x, y } = tileCoordToPixelCoord(position, tileWidth, tileHeight);

    const sprite = (() => {
      if (entity === getPlayerEntity()) {
        return config.sprites[Sprites.Hero];
      }

      // TODO have a component to differentiate them if things other than walls have no health
      const isWall = !hasComponent(Health, entity)
      if (isWall) {
        return config.sprites[Sprites.Wall];
      } else {
        return config.sprites[Sprites.Enemy];
      }
    })()

    const object = objectPool.get(entity, "Sprite");
    object.setComponent({
      id: Position.id,
      once: (gameObject) => {
        gameObject.setTexture(sprite.assetKey, sprite.frame);
        gameObject.setPosition(x, y);
      },
    });
  });

  // hide objects that lost their position
  defineComponentSystem(world, Position, (update) => {
    const position = update.value[0];
    const prevPosition = update.value[1];

    if (position) return;

    // only remove for the selected arena
    const arenaEntity = getArenaEntity();
    if (prevPosition?.layer !== arenaEntity) return;

    // remove destroyed objects
    const object = objectPool.get(update.entity, "Existing");
    if (object) {
      object.removeComponent(Position.id, true);
      object.despawn();
    }
  });
}
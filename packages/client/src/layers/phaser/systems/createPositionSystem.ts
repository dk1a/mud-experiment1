import { tileCoordToPixelCoord } from "@latticexyz/phaserx";
import { defineComponentSystem, defineRxSystem, defineSystem, defineUpdateSystem, getComponentValue, Has } from "@latticexyz/recs";
import { combineLatest, concat } from "rxjs";
import { NetworkLayer } from "../../network";
import { Tileset } from "../assets/tilesets/overworldTileset";
import { Assets, Sprites } from "../constants";
//import { Assets, Sprites } from "../constants";
import { PhaserLayer } from "../types";

export function createPositionSystem(network: NetworkLayer, phaser: PhaserLayer) {
  const {
    world,
    components: { Position, Armor },
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
  defineSystem(world, [Has(Position), Has(Armor)], (update) => {
    const position = getComponentValue(Position, update.entity);
    if (!position) return;

    // only display positions for the selected arena
    const arenaEntity = getArenaEntity();
    if (position?.layer !== arenaEntity) return;

    const { x, y } = tileCoordToPixelCoord(position, tileWidth, tileHeight);

    const sprite = (() => {
      // TODO using armor to identify walls is kinda dumb, especially since you might wana make them non-attackable
      const armor = getComponentValue(Armor, update.entity)?.value ?? 0
      if (armor > 1e12) {
        return config.sprites[Sprites.Wall];
      } else {
        return config.sprites[Sprites.Hero];
      }
    })()

    const object = objectPool.get(update.entity, "Sprite");
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
    console.log('removed', update.entity)
    const object = objectPool.get(update.entity, "Sprite");
    object.removeComponent(Position.id, true);
    object.despawn();
  });
}
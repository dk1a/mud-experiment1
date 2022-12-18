import {
  defineSceneConfig,
  AssetType,
  defineScaleConfig,
  defineMapConfig,
  defineCameraConfig,
} from "@latticexyz/phaserx";
import { Sprites, Assets, Maps, Scenes, TILE_HEIGHT, TILE_WIDTH } from "./constants";
import urizen from "./assets/tilesets/urizen.png";
import { Tileset } from "./assets/tilesets/urizenTileset";
const ANIMATION_INTERVAL = 200;

export const phaserConfig = {
  sceneConfig: {
    [Scenes.Main]: defineSceneConfig({
      assets: {
        [Assets.UrizenTileset]: {
          type: AssetType.SpriteSheet,
          key: Assets.UrizenTileset,
          path: urizen,
          options: {
            frameWidth: TILE_WIDTH,
            frameHeight: TILE_HEIGHT,
          }
        },
      },
      maps: {
        [Maps.Main]: defineMapConfig({
          chunkSize: TILE_WIDTH * 64, // tile size * tile amount
          tileWidth: TILE_WIDTH,
          tileHeight: TILE_HEIGHT,
          backgroundTile: [Tileset.Ground2],
          animationInterval: ANIMATION_INTERVAL,
          tileAnimations: {},
          layers: {
            layers: {
              Background: { tilesets: ["Default"], hasHueTintShader: true },
              Foreground: { tilesets: ["Default"], hasHueTintShader: true },
            },
            defaultLayer: "Background",
          },
        }),
      },
      sprites: {
        [Sprites.Wall]: {
          assetKey: Assets.UrizenTileset,
          frame: Tileset.StoneWall1,
        },
        [Sprites.Hero]: {
          assetKey: Assets.UrizenTileset,
          frame: Tileset.Hero1,
        },
        [Sprites.Enemy]: {
          assetKey: Assets.UrizenTileset,
          frame: Tileset.Enemy1,
        },
      },
      animations: [],
      tilesets: {
        Default: { assetKey: Assets.UrizenTileset, tileWidth: TILE_WIDTH, tileHeight: TILE_HEIGHT },
      },
    }),
  },
  scale: defineScaleConfig({
    parent: "phaser-game",
    zoom: 4,
    mode: Phaser.Scale.NONE,
  }),
  cameraConfig: defineCameraConfig({
    pinchSpeed: 1,
    wheelSpeed: 1,
    maxZoom: 4,
    minZoom: 1,
  }),
  cullingChunkSize: TILE_HEIGHT * 16,
};

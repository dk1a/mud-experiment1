import {
  defineSceneConfig,
  AssetType,
  defineScaleConfig,
  defineMapConfig,
  defineCameraConfig,
} from "@latticexyz/phaserx"
import { Scenes, Maps, Assets, Sprites, TILE_WIDTH, TILE_HEIGHT } from "./constants"

const ANIMATION_INTERVAL = 200;

export const config = {
  sceneConfig: {
    [Scenes.Main]: defineSceneConfig({
      assets: {
        [Assets.UrizenBasicTileset]: {
          type: AssetType.SpriteSheet,
          key: Assets.UrizenBasicTileset,
          path: "tilesets/urizen-basic.json",
          options: {
            frameHeight: 12,
            frameWidth: 12,
          },
        },
        [Assets.UrizenFantasyMedievalTileset]: {
          type: AssetType.SpriteSheet,
          key: Assets.UrizenFantasyMedievalTileset,
          path: "tilesets/urizen-fantasy-medieval.json",
          options: {
            frameHeight: 12,
            frameWidth: 12,
          },
        },
      },
      maps: {
        [Maps.Main]: defineMapConfig({
          chunkSize: TILE_WIDTH * 64, // tile size * tile amount
          tileWidth: TILE_WIDTH,
          tileHeight: TILE_HEIGHT,
          backgroundTile: [41 /* urizen-basic sand */],
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
        [Sprites.Character]: {
          assetKey: Assets.UrizenFantasyMedievalTileset,
          frame: Sprites.Character,
        },
        [Sprites.Wall]: {
          assetKey: Assets.UrizenBasicTileset,
          frame: Sprites.Wall,
        },
      },
      animations: [],
      tilesets: {
        Default: { assetKey: Assets.UrizenBasicTileset, tileWidth: TILE_WIDTH, tileHeight: TILE_HEIGHT },
      },
    }),
  },
  scale: defineScaleConfig({
    parent: "phaser-game",
    zoom: 2,
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
import { defineComponent, Metadata, Type, World } from "@latticexyz/recs";

export function defineLayeredCoordComponent<M extends Metadata>(
  world: World,
  options?: { id?: string; metadata?: M; indexed?: boolean }
) {
  return defineComponent<{ x: Type.Number, y: Type.Number, layer: Type.String }, M>(
    world, { x: Type.Number, y: Type.Number, layer: Type.String },
    options
  );
}
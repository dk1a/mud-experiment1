import { defineComponent, Metadata, Type, World } from "@latticexyz/recs";

export function defineEntityArrayComponent<M extends Metadata>(
  world: World,
  options?: { id?: string; metadata?: M; indexed?: boolean }
) {
  return defineComponent<{ value: Type.EntityArray }, M>(world, { value: Type.EntityArray }, options);
}
import { defineComponent, Metadata, Type, World } from "@latticexyz/recs";

export function defineEntityComponent<M extends Metadata>(
  world: World,
  options?: { id?: string; metadata?: M; indexed?: boolean }
) {
  return defineComponent<{ value: Type.Entity }, M>(world, { value: Type.Entity }, options);
}
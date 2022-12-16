import { defineComponent, Metadata, Type, World } from "@latticexyz/recs";

export function defineNumberArrayComponent<M extends Metadata>(
  world: World,
  options?: { id?: string; metadata?: M; indexed?: boolean }
) {
  return defineComponent<{ value: Type.NumberArray }, M>(world, { value: Type.NumberArray }, options);
}
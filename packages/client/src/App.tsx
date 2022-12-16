import { TxQueue } from "@latticexyz/network";
import { World } from "@latticexyz/recs";
import { SystemTypes } from "contracts/types/SystemTypes";
import { useComponentValueStream } from "@latticexyz/std-client";
import { components } from ".";

import { setupPhaser } from "./phaser";

type Props = {
  world: World;
  systems: TxQueue<SystemTypes>;
  components: typeof components;
  phaser: Awaited<ReturnType<typeof setupPhaser>>
};

export const App = ({ systems, components }: Props) => {
  const roster = useComponentValueStream(components.Roster);
  const queue = useComponentValueStream(components.Queue);

  

  return (
    <>
      <div>
        Roster: <span>{roster?.value ?? "??"}</span>
      </div>
      <div>
        queue: <span>{queue?.value ?? "??"}</span>
      </div>
      <button
        type="button"
        onClick={(event) => {
          event.preventDefault();
          systems["system.ArenaInit"].executeTyped();
        }}
      >
        Join
      </button>
    </>
  );
};

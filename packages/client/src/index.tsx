import ReactDOM from "react-dom/client";
import { setupMUDNetwork } from "@latticexyz/std-client";
import { createWorld } from "@latticexyz/recs";
import { SystemTypes } from "contracts/types/SystemTypes";
import { SystemAbis } from "contracts/types/SystemAbis.mjs";
import { defineNumberComponent, defineCoordComponent } from "@latticexyz/std-client";
import { defineNumberArrayComponent } from "./components/NumberArrayComponent"
import { config } from "./config";
import { App } from "./App";
//import { GodID as SingletonID } from "@latticexyz/network";

import { setupPhaser } from "./phaser"

const rootElement = document.getElementById("react-root");
if (!rootElement) throw new Error("React root not found");
const root = ReactDOM.createRoot(rootElement);

// The world contains references to all entities, all components and disposers.
const world = createWorld();
//export const singletonIndex = world.registerEntity({ id: SingletonID });

// Components contain the application state.
// If a contractId is provided, MUD syncs the state with the corresponding
export const components = {
  ArenaStartTime: defineNumberComponent(world, {
    metadata: {
      contractId: "component.ArenaStartTime",
    },
  }),
  Armor: defineNumberComponent(world, {
    metadata: {
      contractId: "component.Armor",
    },
  }),
  Damage: defineNumberComponent(world, {
    metadata: {
      contractId: "component.Damage",
    },
  }),
  Energy: defineNumberComponent(world, {
    metadata: {
      contractId: "component.Energy",
    },
  }),
  EnergySpent: defineNumberComponent(world, {
    metadata: {
      contractId: "component.EnergySpent",
    },
  }),
  FromPrototype: defineNumberComponent(world, {
    metadata: {
      contractId: "component.FromPrototype",
    },
  }),
  Health: defineNumberComponent(world, {
    metadata: {
      contractId: "component.Health",
    },
  }),
  // Coord
  Position: defineCoordComponent(world, {
    metadata: {
      contractId: "component.Position",
    },
  }),
  // Uint256Set
  Queue: defineNumberArrayComponent(world, {
    metadata: {
      contractId: "component.Queue",
    },
  }),
  QueueNonce: defineNumberComponent(world, {
    metadata: {
      contractId: "component.QueueNonce",
    },
  }),
  // Uint256Set
  Roster: defineNumberArrayComponent(world, {
    metadata: {
      contractId: "component.Roster",
    },
  }),
  WinCount: defineNumberComponent(world, {
    metadata: {
      contractId: "component.WinCount",
    },
  }),
};

// This is where the magic happens
setupMUDNetwork<typeof components, SystemTypes>(
  config,
  world,
  components,
  SystemAbis
).then(({ startSync, systems }) => {
  setupPhaser().then((phaser) => {
    // After setting up the network, we can tell MUD to start the synchronization process.
    startSync();

    root.render(<App world={world} systems={systems} components={components} phaser={phaser} />);
  });  
});


import { createWorld, EntityID, getComponentValue, Has, HasValue, runQuery } from "@latticexyz/recs";
import { setupDevSystems } from "./setup";
import { createActionSystem, defineNumberComponent, setupMUDNetwork } from "@latticexyz/std-client";
import { SystemTypes } from "contracts/types/SystemTypes";
import { SystemAbis } from "contracts/types/SystemAbis.mjs";
import { GameConfig, getNetworkConfig } from "./config";
import { defineEntityComponent } from "./components/EntityComponent";
import { defineEntityArrayComponent } from "./components/EntityArrayComponent";
import { defineLayeredCoordComponent } from "./components/LayeredCoordComponent";
import { Coord } from "@latticexyz/utils";
import { createFaucetService } from "@latticexyz/network";

/**
 * The Network layer is the lowest layer in the client architecture.
 * Its purpose is to synchronize the client components with the contract components.
 */
export async function createNetworkLayer(config: GameConfig) {
  console.log("Network config", config);

  // --- WORLD ----------------------------------------------------------------------
  const world = createWorld();

  // --- COMPONENTS -----------------------------------------------------------------
  const addComponents = {
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
    FromPrototype: defineEntityComponent(world, {
      metadata: {
        contractId: "component.FromPrototype",
      },
    }),
    Health: defineNumberComponent(world, {
      metadata: {
        contractId: "component.Health",
      },
    }),
    Position: defineLayeredCoordComponent(world, {
      metadata: {
        contractId: "component.Position",
      },
    }),
    Queue: defineEntityArrayComponent(world, {
      metadata: {
        contractId: "component.Queue",
      },
    }),
    QueueNonce: defineNumberComponent(world, {
      metadata: {
        contractId: "component.QueueNonce",
      },
    }),
    Roster: defineEntityComponent(world, {
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

  // --- SETUP ----------------------------------------------------------------------
  const { txQueue, systems, components, txReduced$, network, startSync, encoders } = await setupMUDNetwork<
    typeof addComponents,
    SystemTypes
  >(getNetworkConfig(config), world, addComponents, SystemAbis);

  // --- ACTION SYSTEM --------------------------------------------------------------
  const actions = createActionSystem(world, txReduced$);

  // --- API ------------------------------------------------------------------------
  function move(toPosition: Coord) {
    const arenaEntity = getArenaEntity();
    if (!arenaEntity) return console.error("arenaEntity is undefined");
    systems["system.Movement"].executeTyped(arenaEntity, toPosition, {gasLimit: 10000000});
  }

  function joinQueue() {
    systems["system.ArenaInit"].executeTyped();
  }

  function upgradeArmor() {
    const arenaEntity = getArenaEntity();
    if (!arenaEntity) return console.error("arenaEntity is undefined");
    systems["system.Upgrade"].upgradeArmor(arenaEntity);
  }

  function upgradeDamage() {
    const arenaEntity = getArenaEntity();
    if (!arenaEntity) return console.error("arenaEntity is undefined");
    systems["system.Upgrade"].upgradeDamage(arenaEntity);
  }

  function getPlayerEntity() {
    const protoEntity = network.connectedAddress.get() as EntityID;

    const query = runQuery([
      HasValue(components.FromPrototype, { value: protoEntity }),
      Has(components.Roster)
    ]);

    // TODO either restrict a protoEntity to 1 entity, or add some way to select the entity
    return [...query][0];
  }

  function getArenaEntity() {
    return getComponentValue(components.Roster, getPlayerEntity())?.value;
  }

  // --- CONTEXT --------------------------------------------------------------------
  const context = {
    world,
    components,
    txQueue,
    systems,
    txReduced$,
    startSync,
    network,
    actions,
    api: { move, joinQueue, upgradeArmor, upgradeDamage, getPlayerEntity, getArenaEntity },
    dev: setupDevSystems(world, encoders, systems),
  };

  /*
  // Faucet setup
  const faucet = config.faucetServiceUrl ? createFaucetService(config.faucetServiceUrl) : undefined;
  const address = network.connectedAddress.get();
  console.log("player address:", address);

  async function requestDrip() {
    const playerIsBroke = (await network.signer.get()?.getBalance())?.lte(utils.parseEther("0.05"));
    if (playerIsBroke) {
      console.info("[Dev Faucet] Dripping funds to player");
      // Double drip
      address && (await faucet?.dripDev({ address })) && (await faucet?.dripDev({ address }));
    }
  }

  requestDrip();
  // Request a drip every 20 seconds
  setInterval(requestDrip, 20000);
  */

  return context;
}

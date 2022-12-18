import React from "react";
import { registerUIComponent } from "../engine";
import { defineQuery, EntityID, getComponentValue, Has, HasValue } from "@latticexyz/recs";
import { map } from "rxjs";
import styled from "styled-components";
import { useComponentValueStream } from "@latticexyz/std-client";


export function registerArenaData() {
  registerUIComponent(
    "ArenaData",
    {
      rowStart: 1,
      rowEnd: 2,
      colStart: 7,
      colEnd: 10,
    },
    (layers) => {
      const {
        network: {
          components,
          network: { connectedAddress },
        },
      } = layers;

      const protoEntity = connectedAddress.get() as EntityID

      const query = defineQuery([
        HasValue(components.FromPrototype, { value: protoEntity }),
        Has(components.Roster)
      ]);

      return query.update$.pipe(map(() => ({ matching: query.matching, components })));
    },
    ({ matching, components: { Roster, Health, Energy } }) => {
      const entity = [...matching][0]
      const arenaEntity = getComponentValue(Roster, entity)?.value

      const health = useComponentValueStream(Health, entity)?.value
      const energy = useComponentValueStream(Energy, entity)?.value

      return (
        <Container>
          <p>Arena entity: {arenaEntity}</p>
          <p>health: {health}</p>
          <p>energy: {energy}</p>
        </Container>
      );
    }
  );
}

const Container = styled.div`
  padding: 1em;
  background-color: rgba(27,28,32,1);
  display: grid;
  align-content: center;
  align-items: center;
  justify-content: center;
  justify-items: center;
  z-index: 100;
  pointer-events: all;
`;
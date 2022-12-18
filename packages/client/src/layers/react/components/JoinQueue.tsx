import React from "react";
import { registerUIComponent } from "../engine";
import { defineQuery, EntityID, getComponentValue, Has, HasValue } from "@latticexyz/recs";
import { map, of } from "rxjs";
import { useComponentValueStream, useQuery } from "@latticexyz/std-client";
import styled from "styled-components";
import { adminEntityId } from "../../../constants";


export function registerJoinQueue() {
  registerUIComponent(
    "JoinQueue",
    {
      rowStart: 1,
      rowEnd: 2,
      colStart: 5,
      colEnd: 7,
    },
    (layers) => {
      return of(layers)
    },
    (layers) => {
      const {
        network: {
          world,
          components: { Queue, WinCount },
          api: { joinQueue },
          network: { connectedAddress },
        },
      } = layers;

      const protoEntity = connectedAddress.get() as EntityID
      const protoEntityIndex = world.entityToIndex.get(protoEntity)
      const adminEntityIndex = world.entityToIndex.get(adminEntityId)

      const entities = useComponentValueStream(Queue, adminEntityIndex)?.value
      const winCount = useComponentValueStream(WinCount, protoEntityIndex)?.value

      return (
        <Container>
          {entities?.includes(protoEntity) ?
            <p>Queued</p>
          :
            <button onClick={() => joinQueue()}>
              Join queue
            </button>
          }
          <p>Queue size: {entities?.length ?? 0}</p>
          <p>A match starts when size == 4</p>
          <p>wins: {winCount}</p>
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

  button {
    font-family: "Space Grotesk", sans-serif;
    font-size: 18px;
    color: #dcdcaa;
    background-color: rgba(27,28,32,1);
    padding: 1em 0.5em;
    border: 1px solid #444;

    &:active {
      background-color: #111;
    }
  }
`;
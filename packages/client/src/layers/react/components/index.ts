import { registerComponentBrowser } from "./ComponentBrowser";
import { registerActionQueue } from "./ActionQueue";
import { registerLoadingState } from "./LoadingState";
import { registerJoinQueue } from "./JoinQueue";
import { registerArenaData } from "./ArenaData";

export function registerUIComponents() {
  registerLoadingState();
  registerComponentBrowser();
  registerActionQueue();
  registerJoinQueue();
  registerArenaData();
}

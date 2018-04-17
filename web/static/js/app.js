import { Application } from "stimulus";

import EventController from "./controllers/event_controller";

const application = Application.start();
application.register("event", EventController);

console.log("\n\nStarting\n\n");

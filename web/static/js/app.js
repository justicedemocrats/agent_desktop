import { Application } from "stimulus";

import EventController from "./controllers/event_controller";
import FormController from "./controllers/form_controller";
import TrackerController from "./controllers/tracker_controller";
import ContactController from "./controllers/contact_controller";
import ReadyController from "./controllers/ready_controller";

const application = Application.start();
application.register("contact", ContactController);
application.register("event", EventController);
application.register("form", FormController);
application.register("tracker", TrackerController);
application.register("ready", ReadyController);

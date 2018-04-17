import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["email"];

  rsvp(ev) {
    if (this.validateEmail()) {
      const event_id = ev.target.id.split("-")[1];
      ev.target.classList.add("button-loader");

      window.superagent
        .post(`/api/events/${event_id}/rsvp`)
        .send({
          email: this.emailTarget.value,
          phone: getVoterAttribute("phone"),
          first: getVoterAttribute("first"),
          last: getVoterAttribute("last")
        })
        .end(function(err, res) {
          ev.target.classList.remove("button-loader");
          ev.innerHTML = "Done!";
        });
    }
  }

  validateEmail() {
    const email = this.emailTarget.value;
    const parent = this.emailTarget.parentNode;

    if (
      email.match(
        /^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/
      )
    ) {
      parent.classList.remove("input-invalid");
      parent.classList.add("input-valid");
      return true;
    } else {
      parent.classList.add("input-invalid");
      return false;
    }
  }
}

function getVoterAttribute(attribute) {
  attribute = "voter_" + attribute;
  attribute = attribute.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
  var regex = new RegExp("[\\?&]" + attribute + "=([^&#]*)"),
    results = regex.exec(location.search);
  return results == null
    ? undefined
    : decodeURIComponent(results[1].replace(/\+/g, " "));
}

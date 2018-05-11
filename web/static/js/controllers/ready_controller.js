import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["button"];

  connect(ev) {
    console.log("connected");
  }

  go(ev) {
    const username = getUrlAttribute("caller");
    this.buttonTarget.classList.add("button-loader");
    window.superagent
      .get(`/api/goready`)
      .end(
        (err, res) =>
          err
            ? console.error("Error forcing ready")
            : console.log("About to go ready...")
      );
  }
}

function getUrlAttribute(attribute) {
  attribute = attribute.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
  var regex = new RegExp("[\\?&]" + attribute + "=([^&#]*)"),
    results = regex.exec(location.search);
  return results == null
    ? undefined
    : decodeURIComponent(results[1].replace(/\+/g, " "));
}

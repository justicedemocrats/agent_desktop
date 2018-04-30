import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["button"];

  track(ev) {
    console.log(this.buttonTarget.getAttribute);
    const reference_name = this.buttonTarget.getAttribute(
      "data-reference-name"
    );

    console.log(reference_name);
    const data = {
      ["Clicked: " + reference_name]: 1,
      phone: getVoterAttribute("phone"),
      first: getVoterAttribute("first"),
      last: getVoterAttribute("last"),
      voter_id: getVoterAttribute("account"),
      caller: getUrlAttribute("caller")
    };

    const candidate = this.buttonTarget
      .getAttribute("data-candidate")
      .toLowerCase()
      .replace(/ /g, "-");

    const form = "clicks";

    window.superagent
      .post(`/api/form/`)
      .send({ candidate, form, data })
      .end((err, res) => {
        console.log(`[tracker]: click on ${reference_name}`);
      });
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

function getUrlAttribute(attribute) {
  attribute = attribute.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
  var regex = new RegExp("[\\?&]" + attribute + "=([^&#]*)"),
    results = regex.exec(location.search);
  return results == null
    ? undefined
    : decodeURIComponent(results[1].replace(/\+/g, " "));
}

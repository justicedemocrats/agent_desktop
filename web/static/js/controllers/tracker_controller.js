import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["button"];

  track(ev) {
    console.log(this.buttonTarget.getAttribute);
    const reference_name = this.buttonTarget.getAttribute(
      "data-reference-name"
    );

    console.log(reference_name);
    const data = { ["Clicked: " + reference_name]: 1 };
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

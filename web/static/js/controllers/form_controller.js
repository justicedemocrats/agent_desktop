import { Controller } from "stimulus";

// const print = s => {
//   console.log(s);
//   return s;
// };

export default class extends Controller {
  static targets = ["container", "submitButton"];

  submit(ev) {
    const data = Array.from(
      this.containerTarget.querySelectorAll("input, textarea")
    )
      .map(
        el =>
          el.tagName.toLowerCase() == "textarea" ||
          el.type == "text" ||
          el.type == "hidden"
            ? [el.name, el.value]
            : el.checked == true
              ? el.type == "checkbox"
                ? [el.name, [el.value]]
                : [el.name, el.value]
              : []
      )
      .filter(kv => kv.length == 2)
      .reduce(
        (acc, [k, v]) =>
          acc[k] === undefined
            ? Object.assign(acc, { [k]: v })
            : Array.isArray(acc[k])
              ? Object.assign(acc, { [k]: acc[k].concat(v) })
              : Object.assign(acc, { [k]: [acc[k]].concat([v]) }),
        {}
      );

    const candidate = this.containerTarget
      .getAttribute("data-candidate")
      .toLowerCase()
      .replace(/ /g, "-");

    const form = this.containerTarget
      .getAttribute("data-form-label")
      .toLowerCase()
      .replace(/ /g, "-");

    this.submitButtonTarget.classList.add("button-loader");
    window.superagent
      .post(`/api/form/`)
      .send({ candidate, form, data })
      .end((err, res) => {
        this.submitButtonTarget.classList.remove("button-loader");
        this.submitButtonTarget.innerText = "Done!";
      });
  }
}

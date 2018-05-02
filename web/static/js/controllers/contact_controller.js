import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [
    "inputInsert",
    "form",
    "emailInput",
    "textInput",
    "dataPhone",
    "container"
  ];

  connect(ev) {
    const phone = this.dataPhoneTarget.value;
    if (window.is_mobile === undefined) {
      window.superagent.get(`/api/lookup/${phone}`).end((err, res) => {
        var is_mobile = err || res.body.is_moble === false;
        this.handleIsMobile(is_mobile);
        window.is_mobile = is_mobile;
      });
    } else {
      this.handleIsMobile(window.is_mobile);
    }
  }

  handleIsMobile(is_mobile) {
    if (is_mobile) {
      this.inputInsertTarget.innerHTML =
        '<input type="tel" style="display: none;" name="number" value="<%= @voter[~s(phone)] %>"/>';
    } else {
      this.inputInsertTarget.innerHTML =
        '<input class="text-input" type="tel" name="number" required="true" data-target="contact.textInput" />' +
        '<p class="input-hint"> You are calling them at a landline. What is their cell phone? </p>';
    }
  }

  toggleText(ev) {
    var keep;
    var remove;

    if (ev.target.checked) {
      keep = this.textInputTarget;
      remove = this.emailInputTarget;
    } else {
      remove = this.textInputTarget;
      keep = this.emailInputTarget;
    }

    keep.setAttribute("required", "required");
    keep.style.display = "block";
    document.querySelector(".input-hint").style.display = "block";

    remove.removeAttribute("required");
    remove.style.display = "none";
  }

  toggleEmail(ev) {
    var keep;
    var remove;

    if (ev.target.checked) {
      remove = this.textInputTarget;
      keep = this.emailInputTarget;
    } else {
      keep = this.textInputTarget;
      remove = this.emailInputTarget;
    }

    keep.setAttribute("required", "required");
    keep.style.display = "block";
    document.querySelector(".input-hint").style.display = "block";

    remove.removeAttribute("required");
    remove.style.display = "none";
  }

  submit(ev) {
    ev.preventDefault();
    var data = toObject(ev.target);

    const widget_id = this.containerTarget.getAttribute("data-widget-id");

    window.superagent
      .post(`/api/send-contact/${widget_id}`)
      .send(data)
      .end((err, res) => {
        this.containerTarget.parentElement.innerHTML =
          "<h3> Message Sent </h3>";
      });
  }
}

function toObject(form) {
  var obj = {};
  var elements = form.querySelectorAll("input, select, textarea");
  for (var i = 0; i < elements.length; ++i) {
    var element = elements[i];
    var name = element.name;
    var value = element.value;

    if (name && (element.type !== "radio" || element.checked === true))
      obj[name] = value;
  }

  return obj;
}

import { Controller } from "@hotwired/stimulus"
import jquery from "jquery"

export default class extends Controller {
  static values = {
    delay: {
      type: Number,
      default: 3000,
    },
    hidden: {
      type: Boolean,
      default: false,
    },
  }

  connect() {
    if (this.hiddenValue === false) {
      this.show()
    }
  }

  show(event) {
    setTimeout(() => {
      this.element.classList.remove("d-none")
      jquery(this.element).find(".toast").toast("show")
      // this.element.style.setProperty("opacity", 1)
    }, this.delay)
  }
}

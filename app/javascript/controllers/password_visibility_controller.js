import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button", "showIcon", "hideIcon", "label"]

  connect() {
    this.render()
  }

  toggle() {
    this.inputTarget.type = this.visible ? "password" : "text"
    this.render()
  }

  render() {
    const visible = this.visible

    this.buttonTarget.setAttribute("aria-pressed", visible)
    this.buttonTarget.setAttribute("aria-label", visible ? "Slėpti slaptažodį" : "Rodyti slaptažodį")
    this.buttonTarget.setAttribute("title", visible ? "Slėpti slaptažodį" : "Rodyti slaptažodį")

    if (this.hasLabelTarget) {
      this.labelTarget.textContent = visible ? "Slėpti slaptažodį" : "Rodyti slaptažodį"
    }

    this.showIconTarget.classList.toggle("hidden", visible)
    this.hideIconTarget.classList.toggle("hidden", !visible)
  }

  get visible() {
    return this.inputTarget.type === "text"
  }
}

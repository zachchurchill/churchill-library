import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["book"]

  filter(event) {
    const query = event.target.value.trim().toLowerCase()

    this.bookTargets.forEach((book) => {
      const matches = book.dataset.title.includes(query)
      book.classList.toggle("hidden", query !== "" && !matches)
    })
  }
}

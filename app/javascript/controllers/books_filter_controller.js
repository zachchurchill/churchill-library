import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    debounceDelay: { type: Number, default: 300 }
  }

  connect() {
    this.timeout = null
    this.abortController = null
  }

  disconnect() {
    this.cancelPendingSearch()
    this.abortPendingRequest()
  }

  search() {
    this.cancelPendingSearch()
    this.timeout = setTimeout(() => {
      this.submit()
    }, this.debounceDelayValue)
  }

  submit(event) {
    event?.preventDefault()
    this.cancelPendingSearch()
    this.fetchResults()
  }

  async fetchResults() {
    const url = this.buildUrl()
    this.abortPendingRequest()
    this.abortController = new AbortController()

    try {
      const response = await fetch(url, {
        headers: {
          Accept: "text/vnd.turbo-stream.html, text/html, application/xhtml+xml"
        },
        signal: this.abortController.signal
      })

      if (!response.ok) {
        window.location.assign(url)
        return
      }

      const body = await response.text()
      window.Turbo.renderStreamMessage(body)
      this.replaceLocation(response.headers.get("X-Canonical-Url") || url)
    } catch (error) {
      if (error.name !== "AbortError") {
        window.location.assign(url)
      }
    }
  }

  buildUrl() {
    const url = new URL(this.element.action, window.location.origin)
    const params = new URLSearchParams()

    new FormData(this.element).forEach((value, key) => {
      const normalizedValue = value.trim()
      if (normalizedValue === "" || (key === "page" && normalizedValue === "1")) return

      params.append(key, normalizedValue)
    })

    url.search = params.toString()
    return url
  }

  replaceLocation(url) {
    const nextUrl = new URL(url, window.location.origin)
    window.history.replaceState({}, "", `${nextUrl.pathname}${nextUrl.search}`)
  }

  cancelPendingSearch() {
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }
  }

  abortPendingRequest() {
    if (this.abortController) {
      this.abortController.abort()
      this.abortController = null
    }
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "backdrop", "form", "message", "messages", "history", "submit", "error"]

  connect() {
    this.storageKey = "churchill-library:librarian-chat-history"
    this.loadHistory()
    this.boundEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.boundEscape)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundEscape)
  }

  open() {
    this.panelTarget.classList.remove("hidden")
    this.backdropTarget.classList.remove("hidden")
    this.messageTarget.focus()
    this.scrollMessages()
  }

  close() {
    this.panelTarget.classList.add("hidden")
    this.backdropTarget.classList.add("hidden")
  }

  clear() {
    sessionStorage.removeItem(this.storageKey)
    this.historyTarget.value = "[]"
    this.messagesTarget.innerHTML = `
      <div class="rounded-md border border-dashed border-slate-300 bg-slate-50 px-4 py-5 text-sm leading-6 text-slate-600">
        Ask about owners, authors, genres, counts, or which books are in the library.
      </div>
    `
    this.clearError()
  }

  async submit(event) {
    event.preventDefault()
    const message = this.messageTarget.value.trim()

    if (message === "") {
      this.showError("Ask the librarian a question first.")
      return
    }

    this.setLoading(true)
    this.clearError()

    try {
      const formData = new FormData(this.formTarget)
      formData.set("message", message)
      formData.set("history", this.historyTarget.value || "[]")

      const response = await fetch(this.formTarget.action, {
        method: "POST",
        headers: { Accept: "text/html" },
        body: formData
      })
      const html = await response.text()

      if (response.status === 401 || response.redirected) {
        window.location.assign(response.url)
        return
      }

      this.applyResponse(html)
      this.messageTarget.value = ""

      if (!response.ok) {
        this.showError("The librarian could not answer right now.")
      }
    } catch (_error) {
      this.showError("The librarian could not answer right now.")
    } finally {
      this.setLoading(false)
      this.scrollMessages()
    }
  }

  handleEscape(event) {
    if (event.key === "Escape") this.close()
  }

  loadHistory() {
    const history = sessionStorage.getItem(this.storageKey)
    if (!history) return

    this.historyTarget.value = history
    this.renderHistory(history)
  }

  renderHistory(history) {
    let messages = []

    try {
      messages = JSON.parse(history)
    } catch (_error) {
      messages = []
    }

    if (messages.length === 0) return

    this.messagesTarget.innerHTML = ""
    messages.forEach((message) => {
      this.messagesTarget.appendChild(this.messageElement(message))
    })
  }

  messageElement(message) {
    const wrapper = document.createElement("div")
    const bubble = document.createElement("div")
    const paragraph = document.createElement("p")
    const isUser = message.role === "user"

    wrapper.className = `flex ${isUser ? "justify-end" : "justify-start"}`
    bubble.className = `max-w-[85%] rounded-md px-3 py-2 text-sm leading-5 ${isUser ? "bg-green-800 text-white" : "bg-white text-slate-800 border border-slate-200"}`
    paragraph.textContent = message.content || ""

    bubble.appendChild(paragraph)
    wrapper.appendChild(bubble)
    return wrapper
  }

  applyResponse(html) {
    const template = document.createElement("template")
    template.innerHTML = html.trim()

    const messages = template.content.querySelector("#librarian-chat-messages")
    const history = template.content.querySelector("[data-librarian-chat-target='history']")

    if (messages) this.messagesTarget.replaceWith(messages)
    if (history) {
      this.historyTarget.replaceWith(history)
      sessionStorage.setItem(this.storageKey, this.historyTarget.value)
    }
  }

  setLoading(isLoading) {
    this.submitTarget.disabled = isLoading
    this.messageTarget.disabled = isLoading
    this.submitTarget.textContent = isLoading ? "Sending" : "Send"
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
  }

  clearError() {
    this.errorTarget.textContent = ""
    this.errorTarget.classList.add("hidden")
  }

  scrollMessages() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
}

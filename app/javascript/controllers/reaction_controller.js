import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["feedback"]
  static values = { messageId: Number }

  async react(event) {
    const button = event.currentTarget
    const reactionType = button.dataset.reactionType
    const username = this.currentUsername()

    if (!username) {
      this.renderFeedback("Informe um username antes de reagir.", "text-danger")
      return
    }

    button.disabled = true

    try {
      const response = await fetch("/api/v1/reactions", {
        method: "POST",
        headers: this.jsonHeaders(),
        body: JSON.stringify({
          message_id: this.messageIdValue,
          reaction_type: reactionType,
          username
        })
      })

      const data = await response.json()
      if (!response.ok) {
        const klass = response.status === 409 ? "text-warning" : "text-danger"
        this.renderFeedback(data.error || "Erro ao reagir.", klass)
        return
      }

      this.updateCounters(data.reactions || {})
      this.highlightButton(button)
      this.renderFeedback("Reação registrada.", "text-success")
      localStorage.setItem("community_username", username)
    } catch (_error) {
      this.renderFeedback("Falha de conexão ao registrar reação.", "text-danger")
    } finally {
      button.disabled = false
    }
  }

  currentUsername() {
    const field = document.querySelector("[data-current-username='true']")
    return field?.value?.trim() || localStorage.getItem("community_username") || ""
  }

  updateCounters(counts) {
    Object.entries(counts).forEach(([type, count]) => {
      const node = this.element.querySelector(`[data-count-for='${type}']`)
      if (node) node.textContent = count
    })
  }

  highlightButton(activeButton) {
    this.element.querySelectorAll("button[data-reaction-type]").forEach((button) => {
      button.classList.remove("btn-primary")
      button.classList.add("btn-outline-secondary")
    })

    activeButton.classList.remove("btn-outline-secondary")
    activeButton.classList.add("btn-primary")
  }

  jsonHeaders() {
    const csrf = document.querySelector("meta[name='csrf-token']")?.content
    return {
      "Content-Type": "application/json",
      Accept: "application/json",
      "X-CSRF-Token": csrf
    }
  }

  renderFeedback(message, klass) {
    if (!this.hasFeedbackTarget) return
    this.feedbackTarget.textContent = message
    this.feedbackTarget.className = `small ${klass}`
  }
}

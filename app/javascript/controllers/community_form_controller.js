import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "description", "submit", "feedback"]
  static values = { listId: String, emptyStateId: String }

  async submit(event) {
    event.preventDefault()

    const name = this.nameTarget.value.trim()
    const description = this.descriptionTarget.value.trim()

    if (!name) {
      this.renderFeedback("Informe o nome da comunidade.", "text-danger")
      return
    }

    this.lockSubmit(true)

    try {
      const response = await fetch("/api/v1/communities", {
        method: "POST",
        headers: this.jsonHeaders(),
        body: JSON.stringify({ name, description })
      })

      const data = await response.json()

      if (!response.ok) {
        this.renderFeedback(data.error || "Erro ao criar comunidade.", "text-danger")
        return
      }

      this.appendHtml(data)
      this.hideEmptyState()
      this.nameTarget.value = ""
      this.descriptionTarget.value = ""
      this.renderFeedback("Comunidade criada com sucesso.", "text-success")
    } catch (_error) {
      this.renderFeedback("Falha de conexão ao criar comunidade.", "text-danger")
    } finally {
      this.lockSubmit(false)
    }
  }

  appendHtml(data) {
    if (!this.hasListIdValue || !data.html) return

    const list = document.getElementById(this.listIdValue)
    if (!list) return

    list.insertAdjacentHTML("afterbegin", data.html)
  }

  hideEmptyState() {
    if (!this.hasEmptyStateIdValue) return

    const emptyState = document.getElementById(this.emptyStateIdValue)
    if (emptyState) emptyState.classList.add("d-none")
  }

  jsonHeaders() {
    const csrf = document.querySelector("meta[name='csrf-token']")?.content
    return {
      "Content-Type": "application/json",
      Accept: "application/json",
      "X-CSRF-Token": csrf
    }
  }

  lockSubmit(locked) {
    if (this.hasSubmitTarget) this.submitTarget.disabled = locked
  }

  renderFeedback(message, klass) {
    if (!this.hasFeedbackTarget) return
    this.feedbackTarget.textContent = message
    this.feedbackTarget.className = `small mt-2 ${klass}`
  }
}

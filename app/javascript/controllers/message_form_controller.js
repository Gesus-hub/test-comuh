import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["username", "content", "submit", "feedback"]
  static values = { listId: String }

  connect() {
    const cached = localStorage.getItem("community_username")
    if (cached && this.hasUsernameTarget && !this.usernameTarget.value) {
      this.usernameTarget.value = cached
    }
  }

  async submit(event) {
    event.preventDefault()

    const username = this.usernameTarget.value.trim()
    const content = this.contentTarget.value.trim()
    const communityId = this.formField("community_id")
    const parentMessageId = this.formField("parent_message_id")

    if (!username || !content || !communityId) {
      this.renderFeedback("Preencha username e conteúdo.", "text-danger")
      return
    }

    this.lockSubmit(true)

    try {
      const response = await fetch("/api/v1/message", {
        method: "POST",
        headers: this.jsonHeaders(),
        body: JSON.stringify({
          username,
          content,
          community_id: communityId,
          parent_message_id: parentMessageId || null
        })
      })

      const data = await response.json()
      if (!response.ok) {
        this.renderFeedback(data.error || "Erro ao criar mensagem.", "text-danger")
        return
      }

      localStorage.setItem("community_username", username)
      this.appendHtml(data)
      this.contentTarget.value = ""
      this.renderFeedback("Mensagem publicada com sucesso.", "text-success")
    } catch (_error) {
      this.renderFeedback("Falha de conexão ao enviar mensagem.", "text-danger")
    } finally {
      this.lockSubmit(false)
    }
  }

  appendHtml(data) {
    if (!this.hasListIdValue) return

    const list = document.getElementById(this.listIdValue)
    if (!list || !data.html) return

    if (data.parent_message_id) {
      list.insertAdjacentHTML("beforeend", data.html)
    } else {
      list.insertAdjacentHTML("afterbegin", data.html)
    }
  }

  formField(name) {
    return this.element.querySelector(`[name='${name}']`)?.value || ""
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

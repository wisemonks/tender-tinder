import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "loading", "endMessage"]
  static values = {
    url: String,
    page: { type: Number, default: 1 },
    hasMore: { type: Boolean, default: true }
  }

  connect() {
    this.observer = new IntersectionObserver(
      entries => this.handleIntersection(entries),
      {
        root: null,
        rootMargin: "200px",
        threshold: 0.1
      }
    )

    if (this.hasLoadingTarget) {
      this.observer.observe(this.loadingTarget)
    }
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  handleIntersection(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting && this.hasMoreValue && !this.loading) {
        this.loadMore()
      }
    })
  }

  async loadMore() {
    if (this.loading || !this.hasMoreValue) return

    this.loading = true
    this.showLoading()

    try {
      const nextPage = this.pageValue + 1
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set('page', nextPage)

      // Preserve existing query params
      const currentParams = new URLSearchParams(window.location.search)
      currentParams.forEach((value, key) => {
        if (key !== 'page') {
          url.searchParams.set(key, value)
        }
      })

      const response = await fetch(url, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (!response.ok) throw new Error('Network response was not ok')

      const data = await response.json()

      if (data.procurements && data.procurements.length > 0) {
        this.appendProcurements(data.procurements)
        this.pageValue = nextPage
        this.hasMoreValue = data.has_more
      } else {
        this.hasMoreValue = false
      }

      if (!this.hasMoreValue) {
        this.showEndMessage()
      }
    } catch (error) {
      console.error('Error loading more procurements:', error)
      this.showError()
    } finally {
      this.loading = false
      this.hideLoading()
    }
  }

  appendProcurements(procurements) {
    const fragment = document.createDocumentFragment()

    procurements.forEach(procurement => {
      const card = this.createProcurementCard(procurement)
      fragment.appendChild(card)
    })

    this.containerTarget.appendChild(fragment)
  }

  createProcurementCard(procurement) {
    const div = document.createElement('div')
    div.className = 'procurement-card bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow'
    div.dataset.procurementId = procurement.id

    div.innerHTML = `
      <div class="flex items-start justify-between">
        <div class="flex-1">
          <div class="flex items-start gap-3 mb-2">
            <a href="${procurement.url}" class="flex-1">
              <h3 class="text-xl font-semibold text-gray-900 hover:text-red-600">
                ${this.escapeHtml(procurement.title)}
              </h3>
            </a>
            <button class="text-2xl focus:outline-none" onclick="window.location.href='${procurement.toggle_starred_url}'">
              <span class="inline-block transform transition-all duration-300 ease-out hover:scale-125 ${procurement.is_starred ? 'text-red-500 drop-shadow-lg' : 'text-gray-300 hover:text-orange-500'}" style="${procurement.is_starred ? 'filter: drop-shadow(0 0 8px rgba(239, 68, 68, 0.6));' : ''}">
                ${procurement.is_starred ? '★' : '☆'}
              </span>
            </button>
          </div>

          <div class="grid grid-cols-2 gap-4 mb-3 text-sm">
            <div>
              <span class="text-gray-500">ID:</span>
              <span class="font-medium text-gray-900">${procurement.external_id}</span>
            </div>
            <div>
              <span class="text-gray-500">Authority:</span>
              <span class="font-medium text-gray-900">${this.escapeHtml(procurement.authority_name || '')}</span>
            </div>
            ${procurement.publication_date ? `
              <div>
                <span class="text-gray-500">Published:</span>
                <span class="font-medium text-gray-900">${procurement.publication_date}</span>
              </div>
            ` : ''}
            ${procurement.deadline_date ? `
              <div>
                <span class="text-gray-500">Deadline:</span>
                <span class="font-medium text-gray-900">${procurement.deadline_date}</span>
              </div>
            ` : ''}
          </div>

          <div class="flex gap-4 items-center mb-3">
            ${procurement.status ? `
              <span class="px-3 py-1 bg-orange-100 text-orange-800 rounded-full text-sm font-medium">
                ${this.escapeHtml(procurement.status)}
              </span>
            ` : ''}
            ${procurement.estimated_value ? `
              <span class="text-gray-700 font-semibold">
                ${this.formatCurrency(procurement.estimated_value)}
              </span>
            ` : ''}
          </div>

          ${procurement.description ? `
            <p class="text-gray-600 text-sm line-clamp-2">
              ${this.escapeHtml(this.truncate(procurement.description, 200))}
            </p>
          ` : ''}
        </div>
      </div>
    `

    return div
  }

  escapeHtml(text) {
    if (!text) return ''
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  truncate(text, length) {
    if (!text || text.length <= length) return text
    return text.substring(0, length) + '...'
  }

  formatCurrency(value) {
    if (!value) return ''
    const num = typeof value === 'string' ? parseFloat(value) : value
    if (isNaN(num)) return ''
    return `${num.toFixed(2)} €`
  }

  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove('hidden')
    }
  }

  hideLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add('hidden')
    }
  }

  showEndMessage() {
    if (this.hasEndMessageTarget) {
      this.endMessageTarget.classList.remove('hidden')
    }
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add('hidden')
    }
  }

  showError() {
    // You can add error handling UI here
    console.error('Failed to load more procurements')
  }
}

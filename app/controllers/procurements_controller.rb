class ProcurementsController < ApplicationController
  include Pagy::Backend
  before_action :set_procurement, only: [ :show, :toggle_starred ]

  def index
    if params[:query].present?
      # Search returns array, not relation, so no pagination
      search_service = ProcurementSearchService.new(query: params[:query], limit: 100)
      @procurements = search_service.search
      @pagy = nil

      # For search results, show count of search results
      @total_count = @procurements.length
      @starred_count = @procurements.count { |p| p.is_starred? }
    else
      # Use pagination for list views
      base_query = params[:starred].present? ? Procurement.starred.recent : Procurement.recent
      @pagy, @procurements = pagy(base_query, limit: 20)

      # For regular views, show total counts
      @total_count = Procurement.count
      @starred_count = Procurement.starred.count
    end

    respond_to do |format|
      format.html
      format.json {
        render json: {
          procurements: @procurements.map { |p| procurement_json(p) },
          pagy: @pagy ? {
            count: @pagy.count,
            page: @pagy.page,
            limit: @pagy.limit,
            pages: @pagy.pages,
            last: @pagy.last,
            next: @pagy.next
          } : nil,
          has_more: @pagy ? @pagy.next.present? : false
        }
      }
    end
  end

  def show
  end

  def toggle_starred
    @procurement.toggle_starred!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @procurement, notice: "Procurement #{@procurement.is_starred? ? 'starred' : 'unstarred'}" }
    end
  end

  private

  def set_procurement
    @procurement = Procurement.find(params[:id])
  end

  def procurement_json(procurement)
    {
      id: procurement.id,
      external_id: procurement.external_id,
      title: procurement.title,
      authority_name: procurement.authority_name,
      publication_date: procurement.publication_date&.strftime("%Y-%m-%d"),
      deadline_date: procurement.deadline_date&.strftime("%Y-%m-%d %H:%M"),
      status: procurement.status,
      estimated_value: procurement.estimated_value,
      description: procurement.description,
      is_starred: procurement.is_starred?,
      url: procurement_path(procurement),
      toggle_starred_url: toggle_starred_procurement_path(procurement)
    }
  end
end

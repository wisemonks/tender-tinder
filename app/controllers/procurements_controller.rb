class ProcurementsController < ApplicationController
  include Pagy::Backend
  before_action :set_procurement, only: [ :show, :toggle_starred ]

  def index
    base_query = params[:starred].present? ? current_user.starred_procurements.recent : current_user.filtered_procurements.recent

    listing_query = if params[:query].present?
      ProcurementSearchService.new(query: params[:query], scope: base_query).search.recent
    else
      base_query
    end

    @pagy, @procurements = pagy(listing_query.includes(:procurement_stars), limit: 20)

    if params[:query].present?
      @total_count = @pagy.count
      @starred_count = listing_query.joins(:procurement_stars).where(procurement_stars: { user_id: current_user.id }).distinct.count
    else
      @total_count = current_user.filtered_procurements.count
      @starred_count = current_user.starred_procurements.count
    end

    respond_to do |format|
      format.html
      format.json do
        render json: {
          procurements: @procurements.map { |procurement| procurement_json(procurement) },
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
      end
    end
  end

  def show
  end

  def toggle_starred
    @procurement.toggle_starred_for!(current_user)

    respond_to do |format|
      format.turbo_stream
      format.json { render json: { id: @procurement.id, is_starred: @procurement.starred_by?(current_user) } }
      format.html { redirect_to @procurement, notice: "Procurement #{@procurement.starred_by?(current_user) ? 'starred' : 'unstarred'}" }
    end
  end

  private

  def set_procurement
    @procurement = accessible_procurements.find(params[:id])
  end

  def accessible_procurements
    Procurement.where(id: current_user.filtered_procurements.select(:id))
      .or(Procurement.where(id: current_user.starred_procurements.select(:id)))
      .distinct
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
      is_starred: procurement.starred_by?(current_user),
      url: procurement_path(procurement),
      toggle_starred_url: toggle_starred_procurement_path(procurement)
    }
  end
end

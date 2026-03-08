class ProcurementFilterScope
  attr_reader :user, :scope, :settings

  def initialize(user:, scope: Procurement.all)
    @user = user
    @scope = scope
    @settings = ScraperSetting.as_hash(user: user)
  end

  def apply
    filtered_scope = scope.distinct
    filtered_scope = apply_text_keywords(filtered_scope)
    filtered_scope = apply_exact_filters(filtered_scope)
    filtered_scope = apply_date_filters(filtered_scope)
    filtered_scope = apply_value_filters(filtered_scope)
    filtered_scope.distinct
  end

  private

  def apply_text_keywords(filtered_scope)
    keywords = ScraperSetting.keyword_list_for(user)
    return filtered_scope if keywords.empty?

    keywords.reduce(filtered_scope.none) do |combined_scope, keyword|
      keyword_scope = ProcurementSearchService.new(query: keyword, scope: filtered_scope).search
      combined_scope.or(keyword_scope)
    end
  end

  def apply_exact_filters(filtered_scope)
    status_label = ScraperSetting.option_label_for("status", settings["status"])
    filtered_scope = filtered_scope.where(status: status_label) if status_label.present?

    contract_type_label = ScraperSetting.option_label_for("contract_type", settings["contract_type"])
    filtered_scope = filtered_scope.where(contract_type: contract_type_label) if contract_type_label.present?

    procedure_label = ScraperSetting.option_label_for("procedure", settings["procedure"])
    filtered_scope = filtered_scope.where(procedure_type: procedure_label) if procedure_label.present?

    cpc_label = ScraperSetting.option_label_for("cpc_category", settings["cpc_category"])
    if cpc_label.present?
      filtered_scope = filtered_scope.where("procurements.cpc_category ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(cpc_label)}%")
    end

    filtered_scope
  end

  def apply_date_filters(filtered_scope)
    if (publication_from = parsed_date(settings["publication_from_date"]))
      filtered_scope = filtered_scope.where("procurements.publication_date >= ?", publication_from.beginning_of_day)
    end

    if (publication_to = parsed_date(settings["publication_to_date"]))
      filtered_scope = filtered_scope.where("procurements.publication_date <= ?", publication_to.end_of_day)
    end

    if (submission_from = parsed_date(settings["submission_from_date"]))
      filtered_scope = filtered_scope.where("procurements.deadline_date >= ?", submission_from.beginning_of_day)
    end

    if (submission_to = parsed_date(settings["submission_to_date"]))
      filtered_scope = filtered_scope.where("procurements.deadline_date <= ?", submission_to.end_of_day)
    end

    filtered_scope
  end

  def apply_value_filters(filtered_scope)
    if (minimum = parsed_decimal(settings["estimated_value_min"]))
      filtered_scope = filtered_scope.where("procurements.estimated_value >= ?", minimum)
    end

    if (maximum = parsed_decimal(settings["estimated_value_max"]))
      filtered_scope = filtered_scope.where("procurements.estimated_value <= ?", maximum)
    end

    filtered_scope
  end

  def parsed_date(value)
    return if value.blank?

    Date.parse(value)
  rescue ArgumentError
    nil
  end

  def parsed_decimal(value)
    return if value.blank?

    BigDecimal(value.to_s)
  rescue ArgumentError
    nil
  end
end

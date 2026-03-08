class SettingsController < ApplicationController
  before_action :ensure_default_settings
  before_action :load_form_options

  def show
    @settings = current_user.scraper_settings.index_by(&:key)
  end

  def update
    errors = []

    ActiveRecord::Base.transaction do
      settings_params.to_h.each do |key, value|
        setting = ScraperSetting.set(key, value, user: current_user)
        next if setting.persisted?

        errors.concat(setting.errors.full_messages)
        raise ActiveRecord::Rollback
      end
    end

    if errors.any?
      @settings = current_user.scraper_settings.index_by(&:key)
      flash.now[:alert] = errors.uniq.join(", ")
      render :show, status: :unprocessable_entity
      return
    end

    redirect_to settings_path, notice: "Nustatymai sėkmingai išsaugoti"
  end

  private

  def ensure_default_settings
    ScraperSetting.initialize_defaults(user: current_user)
  end

  def load_form_options
    @status_options = ScraperSetting::STATUS_OPTIONS
    @contract_type_options = ScraperSetting::CONTRACT_TYPE_OPTIONS
    @procedure_options = ScraperSetting::PROCEDURE_OPTIONS
    @cpc_category_options = ScraperSetting::CPC_CATEGORY_OPTIONS
  end

  def settings_params
    params.require(:settings).permit(
      :keywords,
      :status,
      :contract_type,
      :procedure,
      :cpc_category,
      :publication_from_date,
      :publication_to_date,
      :submission_from_date,
      :submission_to_date,
      :estimated_value_min,
      :estimated_value_max,
      :digest_emails
    )
  end
end

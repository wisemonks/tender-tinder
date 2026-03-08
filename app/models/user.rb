class User < ApplicationRecord
  has_many :scraper_settings, dependent: :destroy
  has_many :procurement_stars, dependent: :destroy
  has_many :starred_procurements, through: :procurement_stars, source: :procurement
  has_many :procurement_matches, dependent: :destroy
  has_many :matched_procurements, through: :procurement_matches, source: :procurement

  after_create_commit :initialize_scraper_settings

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def filtered_procurements(scope: Procurement.all)
    ProcurementFilterScope.new(user: self, scope: scope).apply
  end

  private

  def initialize_scraper_settings
    ScraperSetting.initialize_defaults(user: self)
  end
end

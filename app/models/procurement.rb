class Procurement < ApplicationRecord
  include PgSearch::Model

  validates :external_id, presence: true, uniqueness: true
  validates :title, presence: true

  # Full-text search configuration
  pg_search_scope :search_by_text,
    against: [ :title, :description, :authority_name, :external_id ],
    using: {
      tsearch: { prefix: true },
      trigram: { threshold: 0.1 }
    }

  scope :starred, -> { where(is_starred: true) }
  scope :recent, -> { order(publication_date: :desc) }

  def toggle_starred!
    update(is_starred: !is_starred)
  end

  def detail_url
    "https://viesiejipirkimai.lt/epps/cft/prepareViewCfTWS.do?resourceId=#{external_id}"
  end
end

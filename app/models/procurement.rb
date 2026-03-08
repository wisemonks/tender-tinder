class Procurement < ApplicationRecord
  include PgSearch::Model

  has_many :procurement_stars, dependent: :destroy
  has_many :starring_users, through: :procurement_stars, source: :user
  has_many :procurement_matches, dependent: :destroy
  has_many :matched_users, through: :procurement_matches, source: :user

  validates :external_id, presence: true, uniqueness: true
  validates :title, presence: true

  pg_search_scope :search_by_text,
    against: [
      :title,
      :description,
      :authority_name,
      :external_id,
      :status,
      :procedure_type,
      :contract_type,
      :cpc_category,
      :cpv_codes,
      :plan_reference,
      :evaluation_criteria,
      :contract_duration
    ],
    using: {
      tsearch: { prefix: true },
      trigram: { threshold: 0.1 }
    }

  scope :recent, -> { order(publication_date: :desc) }

  def starred_by?(user)
    return false unless user

    if association(:procurement_stars).loaded?
      procurement_stars.any? { |star| star.user_id == user.id }
    else
      procurement_stars.exists?(user_id: user.id)
    end
  end

  def toggle_starred_for!(user)
    star = procurement_stars.find_by(user: user)

    if star
      star.destroy!
      false
    else
      procurement_stars.create!(user: user)
      true
    end
  end

  def detail_url
    url.presence || "https://viesiejipirkimai.lt/epps/cft/prepareViewCfTWS.do?resourceId=#{external_id}"
  end
end

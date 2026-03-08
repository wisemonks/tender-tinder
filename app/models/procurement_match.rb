class ProcurementMatch < ApplicationRecord
  belongs_to :user
  belongs_to :procurement

  validates :procurement_id, uniqueness: { scope: :user_id }
end

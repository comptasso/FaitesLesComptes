class CashControl < ActiveRecord::Base
  belongs_to :cash

  validates :date, :cash_id, :amount, presence: true
  validates :amount, numericality: true
end

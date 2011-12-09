class BankAccount < ActiveRecord::Base
  belongs_to :organism
  has_many :check_deposits
end

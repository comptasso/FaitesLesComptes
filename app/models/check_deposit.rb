class CheckDeposit < ActiveRecord::Base
  has_many :lines
  belongs_to :bank_account
end

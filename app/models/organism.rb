class Organism < ActiveRecord::Base
  has_many :books, dependent: :destroy
  has_many :destinations, dependent: :destroy
  has_many :natures, dependent: :destroy
  has_many :bank_accounts, dependent: :destroy
  has_many :lines, :through=>:books
  has_many :check_deposits, through: :bank_accounts
  
end

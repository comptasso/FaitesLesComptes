class Organism < ActiveRecord::Base
  has_many :books, dependent: :destroy
  has_many :destinations, dependent: :destroy
  has_many :natures, dependent: :destroy
  has_many :bank_accounts, dependent: :destroy
  has_many :lines, :through=>:books
  has_many :check_deposits, through: :bank_accounts
  has_many :periods, dependent: :destroy
  has_many :cashes, dependent: :destroy

   # retourne le nombre d'exercices ouverts de l'organisme
  def nb_open_periods
    Period.where('organism_id=? AND open = ?', self.id, true).count
  end
  
end

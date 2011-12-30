# -*- encoding : utf-8 -*-

class Organism < ActiveRecord::Base
  has_many :books, dependent: :destroy
  has_many :destinations, dependent: :destroy
  has_many :natures, dependent: :destroy
  has_many :bank_accounts, dependent: :destroy
  has_many :lines, :through=>:books
  has_many :check_deposits, through: :bank_accounts
  has_many :periods, dependent: :destroy
  has_many :cashes, dependent: :destroy
  has_many :income_books, dependent: :destroy
  has_many :outcome_books, dependent: :destroy

  after_create :create_default

   # retourne le nombre d'exercices ouverts de l'organisme
  def nb_open_periods
    Period.where('organism_id=? AND open = ?', self.id, true).count
  end

  def number_of_non_deposited_checks
    self.lines.non_depose.count
  end

  def value_of_non_deposited_checks
    self.lines.non_depose.sum(:credit)
  end

  def create_default
    self.income_books.create(:title=>'Recettes', :description=>'Livre des recettes')
    self.outcome_books.create(title: 'Dépenses', description: 'Livre des dépenses')
  end
  
end

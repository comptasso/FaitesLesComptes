# coding: utf-8

# La tables books représente les livres. 
# Une sous classe IncomeOutcomeBook représente les livres de recettes et de dépénses
# chacun au travers de leur classe dérivée (IncomeBook et OutcomeBook)
# 
# Les journaux sont aussi représentés par la classe Book
# ?? Faire une classe dérivée Ledger ?
# Actuellement il y a un journal d'OD systématiquement créé pour chaque organisme
#
class Book < ActiveRecord::Base

  include Utilities::JcGraphic

  # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold

  attr_accessible :title, :description, :abbreviation
  
  belongs_to :organism
  has_many :writings, :dependent=>:destroy
  has_many :compta_lines, :through=>:writings

  scope :in_outs, where(:type=> ['IncomeBook', 'OutcomeBook'])

 
  # TODO introduce uniqueness and scope
  validates :title, :abbreviation, presence: true
  
  def book_type
    self.class.name
  end

 
  # astuces trouvéexs dans le site suivant
  # http://code.alexreisner.com/articles/single-table-inheritance-in-rails.html
  # également ajouté un chargement des enfants dans l'initilizer development.rb
  def self.inherited(child)
    child.instance_eval do
      def model_name
        Book.model_name
      end
    end
    super
  end

 

end

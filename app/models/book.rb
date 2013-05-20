# coding: utf-8


require 'strip_arguments'


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

  strip_before_validation(:title, :description, :abbreviation)

  # TODO introduce uniqueness and scope

  validates :title, presence: true, :format=>{:with=>NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}
  validates :abbreviation, presence: true, :format=>{:with=>/\A[A-Z]{1}[A-Z0-9]{1,3}\Z/}
  validates :description, :format=>{:with=>NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true
  
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

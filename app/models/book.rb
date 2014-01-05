# coding: utf-8


require 'strip_arguments'


# La tables books représente les livres. 
# Une sous classe IncomeOutcomeBook représente les livres de recettes et de dépénses
# chacun au travers de leur classe dérivée (IncomeBook et OutcomeBook)
# 
# Les journaux sont aussi représentés par la classe Book
# 
# Il y a un journal d'OD et un d'AN systématiquement créé pour chaque organisme
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

  strip_before_validation :title, :description, :abbreviation

  # ATTENTION si on abandonne la logique des schémas pour la base de données, alors
  # il faudrait modifier les uniqueness pour introduire un scope.

  validates :title, presence: true, uniqueness:true, :format=>{:with=>NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}
  validates :abbreviation, presence: true, uniqueness:true,  :format=>{:with=>/\A[A-Z]{1}[A-Z0-9]{1,3}\Z/}
  validates :description, :format=>{:with=>NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true
  validates :organism_id, presence:true
  
  def book_type
    self.class.name
  end
  
  # TODO à déplacer dans un initializer

 
  # astuces trouvéexs dans le site suivant
  # http://www.alexreisner.com/code/single-table-inheritance-in-rails
  # 
  # Le but de cette méthode est de redéfinir la méthode model_name qui est utilisée
  # pour la génération des path. Ainsi un IncomeBook répond quand même Book à la méthode model_name
  # et la construction des path reste correcte.
  def self.inherited(child)
    child.instance_eval do
      def model_name
        Book.model_name
      end
    end
    super
  end

 

end

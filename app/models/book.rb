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
  
  belongs_to :organism
  has_many :writings, :dependent=>:destroy
  has_many :compta_lines, :through=>:writings

  # has_many :lines, dependent: :destroy
  # les chèques en attente de remise en banque
  #  has_many :pending_checks,
  #    :class_name=>'Line',
  #    :conditions=>'payment_mode = "Chèque" and credit > 0 and check_deposit_id IS NULL'

  # les lignes qui relèvent d'une recette ou d'une dépense (sans leur contrepartie)
  # sélectionnées donc sur la présence de nature

#  has_many :inouts,
#    :class_name=>'Line',
#    :conditions=> 'nature_id IS NOT NULL'

  
  # TODO introduce uniqueness and scope
  validates :title, presence: true
  
  # renvoie les soldes mensuels du livre pour l'ensemble des mois de l'exercice
  # sous la forme d'un hash avec comme clé 'mm-yyyy' pour identifier les mois.
  # monthly_value est définie dans Utilities::Sold
  def monthly_datas(period)
    Hash[period.list_months('%m-%Y').map {|m| [m, monthly_value(m)]}]
  end

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

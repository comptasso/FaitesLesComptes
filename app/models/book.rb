# coding: utf-8

class Book < ActiveRecord::Base

  include Utilities::JcGraphic

  # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold
  
  belongs_to :organism
  has_many :lines, dependent: :destroy 
   # les chèques en attente de remise en banque
  has_many :pending_checks,
    :class_name=>'Line',
    :conditions=>'payment_mode = "Chèque" and credit > 0 and check_deposit_id IS NULL'

 
   
  # TODO introduce uniqueness and scope
  validates :title, presence: true
  
  # renvoie les soldes mensuels du livre pour l'ensemble des mois de l'exercice
  # sous la forme d'un hash avec comme clé 'mm-yyyy' pour identifier les mois
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

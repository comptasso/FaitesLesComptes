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
   
  validates :title, presence: true  
 
  attr_reader  :monthly_solds

  # renvoie les soldes mensuels du livre pour l'ensemble des mois de l'exercice
  def monthly_datas(period)
    a={}
    @monthly_solds= period.list_months('%m-%Y').collect do |m|
      ls= self.lines.month(m)
      a[m] = ls.sum(:credit) - ls.sum(:debit)
    end
    a
  end

  # renvoie le solde d'un livre pour un mois déterminé par date
  def monthly_value(date)
    ls=self.lines.mois(date)
    # TODO : on peut certainement faire mieux sur le plan de la requête
    ls.sum(:credit)-ls.sum(:debit)
  end




  
 

  


end

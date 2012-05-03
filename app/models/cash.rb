class Cash < ActiveRecord::Base
   # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold

   include Utilities::JcGraphic

  # attr_reader :chart_value_method
  
  belongs_to :organism
  has_many :lines
  has_many :cash_controls
  has_many :d_transfers, :as=>:debitable, :class_name=>'Transfer'
  has_many :c_transfers, :as=>:creditable, :class_name=>'Transfer'

  validates :name, :presence=>true, :uniqueness=>{:scope=>:organism_id}

  # calcule le solde d'une caisse à une date donnée en partant du début de l'exercice
  # qui inclut cette date
  # TODO en fait j'ai modifié ce comportement pour ne pas avoir ce problème de report
  # A réfléchir
  def sold(date=Date.today)
    # period=self.organism.find_period(date)
    ls= self.lines.where('line_date <= ?', date)
    date <= Date.today ? ls.sum(:credit)-ls.sum(:debit) : 0
  end


  # méthode utilisée par le module JcGraphic pour la construction des graphiques
  def monthly_value(date)
     ls= self.lines.where('line_date <= ?', date)
    date <= Date.today ? ls.sum(:credit)-ls.sum(:debit) : 'null'
  end

  # Calcule les dates possibles pour un contrôle de caisse en fonction de l'exercice,
  # de la date du jour et des contrôles antérieurs.
  # on ne peut saisir un contrôle antérieur aux contrôles existants.
  # utilisé notamment par cash_control_controller#new
#  def range_date_for_cash_control(period)
#    last_cc = self.cash_controls.for_period(period).last(order: 'date ASC')
#    min_date= last_cc ? [period.start_date, last_cc.date].max : period.start_date
#    return min_date, [period.close_date, Date.today].min
#  end

  def to_s
    name
  end

  def to_option
    "#{self.class.name}_#{id}"
  end

  



end

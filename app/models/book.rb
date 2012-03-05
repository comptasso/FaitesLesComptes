# coding: utf-8

class Book < ActiveRecord::Base

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
 
  attr_reader :graphic, :monthly_solds



  # cette partie GRAPHIQUE permet de construire un graphique à partir des données du livre

  # permet de retourner ou de créer la variable d'instance
  def graphic(period=nil)
    @graphic ||= default_graphic(period)
  end

  # construit un graphique des données mensuelles du livre par défaut avec deux exercices
  #
  def default_graphic(period=nil)
    period ||= self.organism.periods.last
    return nil unless period # il n'y a aucun exercice
    if period.previous_period?
      @graphic = two_years_monthly_graphic(period)
    else
      @graphic= one_year_monthly_graphic(period)
    end
  end


  # la construction d'un graphique sur un an
  def one_year_monthly_graphic(period)
    mg= Utilities::Graphic.new(self.ticks(period))
    mg.add_serie(:legend=>period.exercice, :datas=>self.monthly_datas_for_chart(period.list_months('%m-%Y')), :period_id=>period.id )
    mg
  end

  # construction d'un graphique sur deux ans
  def two_years_monthly_graphic(period)
    mg= Utilities::Graphic.new(self.ticks(period))
    months= period.list_months('%m-%Y') # les mois du dernier exercice servent de référence
    pp=period.previous_period
    mg.add_serie(:legend=>pp.exercice, :datas=>previous_year_monthly_datas_for_chart(months), :period_id=>pp.id )
    mg.add_serie(:legend=>period.exercice, :datas=>self.monthly_datas_for_chart(months), :period_id=>period.id )
    mg
  end

  # renvoie les soldes mensuels du livre pour l'ensemble des mois de l'exercice
  def monthly_datas(period)
    a={}
    period.list_months('%m-%Y').each do |m|
      ls= self.lines.month(m)
      a[m] =(ls.sum(:credit) - ls.sum(:debit))
    end
    @monthly_solds = a
  end

  # renvoie le solde d'un livre pour un mois donné au format mm-yyyy
  def monthly_sold(month)
    ls=self.lines.month(month)
    ls.sum(:credit)-ls.sum(:debit)
  end


  #  protected

  def ticks(period)
    period.list_months('%b')
  end

  
  # calcule le total des lignes pour chacun des mois de l'exercice transmis en paramètres
  # renvoie un array donnant le total credit - debit des lignes des mois
  # En pratique, on appelle les deux méthodes avec la même variable months
  # pour avoir des séries de même longueur même lorsque les éxercices sont de longueur différentes.
  # month doit être au format mm-yyyy
  # 
  def monthly_datas_for_chart(months)
    months.map {|m| self.monthly_sold(m)}
  end

  def previous_year_monthly_datas_for_chart(months)
    a=[]
    months.each do |m|
      month= m[/^\d{2}/]
      year = m[/\d{4}$/].to_i - 1
      a << self.monthly_sold("#{month}-#{year}")
    end
    a
  end

  


end

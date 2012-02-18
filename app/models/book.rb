class Book < ActiveRecord::Base

  # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold
  
  belongs_to :organism
  has_many :lines, dependent: :destroy
   
  validates :title, presence: true 
 
  attr_reader :graphic, :monthly_solds
  
  def default_graphic
    if self.organism.periods.count > 1
      @graphic = two_years_monthly_graphic(self.organism.periods.last)
    elsif self.organism.periods.count == 1
      @graphic= one_year_monthly_graphic
    else
      @graphic=nil
    end
  end

  def one_year_monthly_graphic
    period = self.organism.periods.last
    mg= Utilities::Graphic.new(self.ticks(period))
    mg.add_serie(:legend=>period.exercice, :datas=>self.monthly_datas_for_chart(period.list_months('%m-%Y')) )
    mg
  end

  def two_years_monthly_graphic(period)
    mg= Utilities::Graphic.new(self.ticks(period))
    months= period.list_months('%m-%Y') # les mois du dernier exercice servent de référence
    pp=period.previous_period
    mg.add_serie(:legend=>pp.exercice, :datas=>previous_year_monthly_datas_for_chart(months) )
    mg.add_serie(:legend=>period.exercice, :datas=>self.monthly_datas_for_chart(months) )
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
  # On utilise les mois de la période (var months) ou ceux fournis par la variable months
  # pour pouvoir avoir des exercices de longueur différente.
  #
  # FIXME il y aura un problème avec les exercices de plus de 12 mois. - A réfléchir
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

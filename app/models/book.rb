class Book < ActiveRecord::Base

  # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold
  
  belongs_to :organism
  has_many :lines, dependent: :destroy
   
  validates :title, presence: true 
 
  attr_reader :graphic
  
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
    mg.add_serie(:legend=>period.exercice, :datas=>self.monthly_datas_for_chart(period) )
    mg
  end

  def two_years_monthly_graphic(last_period)
    mg= Utilities::Graphic.new(self.ticks(last_period))
    months= last_period.list_months('%m') # les mois du dernier exercice servent de référence
    pp=last_period.previous_period

    mg.add_serie(:legend=>pp.exercice, :datas=>self.monthly_datas_for_chart(pp, months) )
    mg.add_serie(:legend=>last_period.exercice, :datas=>self.monthly_datas_for_chart(last_period) )
    mg
  end

  protected

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
  def monthly_datas_for_chart(period, months=nil)
    months ||= period.list_months('%m')
    md = self.monthly_datas(period)
    datas= months.map do |m|
      result = md.detect {|r| r["Month"] == m }
      result && result["total_month"] || 0 # cette partie est utile pour mettre des zeros sur les mois qui n'auraient pas de valeur
    end
    datas
  end

  def monthly_datas(period)
    sql="select  strftime('%m', line_date) as Month, sum(credit) -sum(debit) as total_month  FROM lines WHERE line_date >= '#{period.start_date}'
          AND line_date <= '#{period.close_date}' AND lines.book_id = #{self.id} GROUP BY Month"
    Line.connection.select_all(sql)
  end


end

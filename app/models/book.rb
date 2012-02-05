class Book < ActiveRecord::Base

  # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold
  
  belongs_to :organism
  has_many :lines, dependent: :destroy
  attr_reader :months, :datas, :previous_datas, :series
  
  validates :title, presence: true

#  def book_type
#    nil
#  end
#
#  def book_type=(type)
#    nil
#  end

  def prepare_graph(period)
    monthly_datas_for_chart(period)
  end

  def months(period,format)
    period.list_months(format)
  end

  

  protected

  # calcule le total des lignes pour chacun des mois de l'exercice transmis en paramètres
  # renvoie deux arrays, le premier donnant le mois, le second donnant le total credit - debit des lignes des mois
def monthly_datas_for_chart(period)
     sql="select  strftime('%m-%Y', line_date) as Month, sum(credit) -sum(debit) as total_month  FROM lines WHERE line_date >= '#{period.start_date}'
  AND line_date <= '#{period.close_date}' AND lines.book_id = #{self.id} GROUP BY Month"
    md= Line.connection.select_all(sql)
    @datas= self.months(period,'%m-%Y').map do |m|
      result = md.detect {|r| r['Month'] == m }
      result && result["total_month"] || 0
    end
   
    self.previous_period_monthly_datas(period)
    self.prepare_series(period)
    
 end

def prepare_series(period)
    if period.previous_period?
    @series = [period.previous_period.exercice, period.exercice ]
    else
    @series=  [period.exercice]
    end
  end

def previous_period_monthly_datas(period)
  if period.previous_period?
    close =period.start_date - 1
    start =close - (period.close_date - period.start_date)
    sql="select  strftime('%m-%Y', line_date) as Month, sum(credit) -sum(debit) as total_month  FROM lines WHERE line_date >= '#{start}'
  AND line_date <= '#{close}' AND lines.book_id = #{self.id} GROUP BY Month"
   md= Line.connection.select_all(sql)
    @previous_datas= self.months(period,'%m-%Y').map do |m|
      result = md.detect {|r| r['Month'] == m }
      result && result["total_month"] || 0
    end
  else
    @previous_datas =  period.nb_months.times.map {|m| 0}
  end
 
end



end

class Book < ActiveRecord::Base

  # utilities::sold définit les méthodes cumulated_debit_before(date) et
  # cumulated_debit_at(date) et les contreparties correspondantes.
  include Utilities::Sold
  
  belongs_to :organism
  has_many :lines, dependent: :destroy
 
  
  validates :title, presence: true

#  def book_type
#    nil
#  end
#
#  def book_type=(type)
#    nil
#  end

  # calcule le total des lignes pour chacun des mois de l'exercice transmis en paramètres
  # renvoie deux arrays, le premier donnant le mois, le second donnant le total credit - debit des lignes des mois
def monthly_datas(period)
     sql="select  strftime('%m-%Y', line_date) as Month, sum(credit) -sum(debit) as total_month  FROM lines WHERE line_date >= '#{period.start_date}'
  AND line_date <= '#{period.close_date}' AND lines.book_id = #{self.id} GROUP BY Month"
    md= Line.connection.select_all(sql)
    datas= period.list_months('%m-%Y').map do |m|
      result = md.detect {|r| r['Month'] == m }
      result && result["total_month"] || 0
    end
    return [period.list_months('%b'),datas]
   end

end

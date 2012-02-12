# coding: utf-8
#
# BookGraph est destiné a représente le graphe d'un livre de comptes sur des périodes mensuelles
# Il est initialisé par le book et l'exercice.
# Si l'exercice n'est pas fourni, il s'agit du dernier existant
#
class Utilities::BookGraph

  attr_reader :legend, :ticks, :first_serie, :second_serie, :period, :book, :nb_values


  def initialize(book, period=nil)
    @book=book
    @period = period || book.organism.periods.last
    raise 'This organism has no period' unless @period
    @nb_values=@period.nb_months
    @nb_series = @period.previous_period? ? 2 : 1
    @legend=[]
    @ticks= @period.list_months('%b')
    if @period.previous_period?
      @first_serie=prepare_serie(@period.previous_period)
      @second_serie=prepare_serie(@period)
    else
      @first_serie=prepare_serie(@period)
    end
  end

 
  def prepare_serie(period)
    @legend << period.exercice
    self.monthly_datas_for_chart(period)
  end

  protected

  # calcule le total des lignes pour chacun des mois de l'exercice transmis en paramètres
  # renvoie un array donnant le total credit - debit des lignes des mois
  def monthly_datas_for_chart(period)
    sql="select  strftime('%m-%Y', line_date) as Month, sum(credit) -sum(debit) as total_month  FROM lines WHERE line_date >= '#{period.start_date}'
          AND line_date <= '#{period.close_date}' AND lines.book_id = #{@book.id} GROUP BY Month"
    md= Line.connection.select_all(sql)
    datas= period.list_months('%m-%Y').map do |m|
      result = md.detect {|r| r['Month'] == m }
      result && result["total_month"] || 0 # cette partie est utile pour mettre des zeros sur les mois qui n'auraient pas de valeur
    end
    datas

  end




end

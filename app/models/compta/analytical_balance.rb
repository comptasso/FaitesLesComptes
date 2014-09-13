# coding: utf-8


# Classe pour construire une balance analytique. Une telle balance est 
# une collection de Destination dont chacune a ensuite une collection de 
# ligne avec des comptes, leur libellé et le total debit et crédit.
#
# La dernière destination regroupe les lignes qui n'ont pas de destinations
class Compta::AnalyticalBalance < ActiveRecord::Base
  
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :from_date, :string
  column :to_date, :string
  column :period_id, :integer
  
  
  
  attr_accessible :from_date, :to_date,  
    :period_id, :from_date_picker, :to_date_picker
  
   pick_date_for :from_date, :to_date # donne les méthodes from_date_picker et to_date_picker
  # utilisées par le input as:date_picker 
  
   
  
   belongs_to :period
   
   validates :from_date, :to_date, :within_period=>true
   validates :from_date, :to_date, :period_id, :presence=>true
   
  
  def self.with_default_values(exercice)
    new(period_id:exercice.id, from_date:exercice.start_date, to_date:exercice.close_date)
  end
  
  def destinations
    period.organism.destinations
  end
  
  def lines
    @lines ||= collect_lines 
  end
  
  protected
  
  def collect_lines
    matable = destinations.map {|d| {d.name=>d.ab_lines(period_id, from_date, to_date)}}
    # TODO ajouter la dernière ligne, celle qui fait le total des écritures 
    # qui n'ont pas de destination
    matable += [{'Sans Activité'=>orphan_lines}]
    matable
  end
  
  # Récupère une table de comptes pour les compta_lines
  # qui n'ont pas de destination
  def orphan_lines
    Account.joins(:compta_lines=>:writing).
      select([:number, :title, "SUM(debit) AS t_debit", "SUM(credit) AS t_credit"]).
        where('destination_id IS NULL AND period_id = ? AND date >= ? AND date <= ?',
        period_id, from_date, to_date).
        group(:title,:number)
  end
end


